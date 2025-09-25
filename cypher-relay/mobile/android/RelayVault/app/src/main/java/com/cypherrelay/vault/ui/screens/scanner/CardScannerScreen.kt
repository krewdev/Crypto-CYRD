package com.cypherrelay.vault.ui.screens.scanner

import android.Manifest
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.cypherrelay.vault.ui.components.SuccessAnimation
import com.cypherrelay.vault.ui.viewmodels.CardScannerViewModel
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberPermissionState
import kotlinx.coroutines.delay
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun CardScannerScreen(
    onCardRedeemed: () -> Unit,
    onBack: () -> Unit,
    viewModel: CardScannerViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val cameraPermissionState = rememberPermissionState(Manifest.permission.CAMERA)
    
    val uiState by viewModel.uiState.collectAsState()
    var showSuccess by remember { mutableStateOf(false) }
    
    LaunchedEffect(cameraPermissionState) {
        if (!cameraPermissionState.status.isGranted) {
            cameraPermissionState.launchPermissionRequest()
        }
    }
    
    LaunchedEffect(uiState) {
        if (uiState is CardScannerUiState.Success) {
            showSuccess = true
            delay(2000)
            onCardRedeemed()
        }
    }
    
    Box(modifier = Modifier.fillMaxSize()) {
        if (cameraPermissionState.status.isGranted) {
            CameraPreview(
                onQrCodeScanned = { qrData ->
                    viewModel.redeemCard(qrData)
                }
            )
            
            // Scanner overlay
            ScannerOverlay()
            
            // Top bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.Start
            ) {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(Color.Black.copy(alpha = 0.5f))
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = Color.White
                    )
                }
            }
            
            // Instructions
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 100.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Scan QR Code",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                
                Spacer(modifier = Modifier.height(8.dp))
                
                Text(
                    text = "Position the code within the frame",
                    fontSize = 16.sp,
                    color = Color.White.copy(alpha = 0.8f)
                )
            }
        } else {
            // Permission denied view
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "Camera Permission Required",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Text(
                    text = "We need camera access to scan your Cypher Relay Card",
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )
                
                Spacer(modifier = Modifier.height(24.dp))
                
                Button(
                    onClick = { cameraPermissionState.launchPermissionRequest() }
                ) {
                    Text("Grant Permission")
                }
            }
        }
        
        // Loading overlay
        if (uiState is CardScannerUiState.Loading) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.7f)),
                contentAlignment = Alignment.Center
            ) {
                Card(
                    modifier = Modifier.padding(32.dp),
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        CircularProgressIndicator()
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        Text(
                            text = "Redeeming your card...",
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }
        }
        
        // Success animation
        if (showSuccess && uiState is CardScannerUiState.Success) {
            SuccessAnimation(
                amount = uiState.amount
            )
        }
        
        // Error dialog
        if (uiState is CardScannerUiState.Error) {
            AlertDialog(
                onDismissRequest = { viewModel.clearError() },
                title = { Text("Error") },
                text = { Text(uiState.message) },
                confirmButton = {
                    TextButton(onClick = { viewModel.clearError() }) {
                        Text("OK")
                    }
                }
            )
        }
    }
}

@Composable
fun CameraPreview(
    onQrCodeScanned: (String) -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val cameraExecutor = remember { Executors.newSingleThreadExecutor() }
    
    AndroidView(
        factory = { ctx ->
            PreviewView(ctx).apply {
                scaleType = PreviewView.ScaleType.FILL_CENTER
            }
        },
        modifier = Modifier.fillMaxSize()
    ) { previewView ->
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            
            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            
            val imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor, QrCodeAnalyzer { qrData ->
                        onQrCodeScanned(qrData)
                    })
                }
            
            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
            
            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }, ContextCompat.getMainExecutor(context))
    }
    
    DisposableEffect(Unit) {
        onDispose {
            cameraExecutor.shutdown()
        }
    }
}

@Composable
fun ScannerOverlay() {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val scannerSize = size.width * 0.7f
        val left = (size.width - scannerSize) / 2
        val top = (size.height - scannerSize) / 2
        
        // Draw dark overlay with cutout
        drawRect(
            color = Color.Black.copy(alpha = 0.6f),
            size = size
        )
        
        // Draw scanner frame
        val path = Path().apply {
            addRoundRect(
                androidx.compose.ui.geometry.RoundRect(
                    left = left,
                    top = top,
                    right = left + scannerSize,
                    bottom = top + scannerSize,
                    cornerRadius = CornerRadius(20.dp.toPx())
                )
            )
        }
        
        clipPath(path, clipOp = androidx.compose.ui.graphics.ClipOp.Difference) {
            drawRect(
                color = Color.Black.copy(alpha = 0.6f),
                size = size
            )
        }
        
        // Draw corner accents
        val cornerLength = 40.dp.toPx()
        val strokeWidth = 3.dp.toPx()
        
        drawCornerAccent(
            left = left,
            top = top,
            cornerLength = cornerLength,
            strokeWidth = strokeWidth
        )
        
        drawCornerAccent(
            left = left + scannerSize - cornerLength,
            top = top,
            cornerLength = cornerLength,
            strokeWidth = strokeWidth,
            rotation = 90f
        )
        
        drawCornerAccent(
            left = left + scannerSize - cornerLength,
            top = top + scannerSize - cornerLength,
            cornerLength = cornerLength,
            strokeWidth = strokeWidth,
            rotation = 180f
        )
        
        drawCornerAccent(
            left = left,
            top = top + scannerSize - cornerLength,
            cornerLength = cornerLength,
            strokeWidth = strokeWidth,
            rotation = 270f
        )
    }
}

fun DrawScope.drawCornerAccent(
    left: Float,
    top: Float,
    cornerLength: Float,
    strokeWidth: Float,
    rotation: Float = 0f
) {
    // Draw corner lines based on rotation
    when (rotation) {
        0f -> {
            // Top-left
            drawLine(
                color = Color.White,
                start = Offset(left, top + cornerLength),
                end = Offset(left, top),
                strokeWidth = strokeWidth
            )
            drawLine(
                color = Color.White,
                start = Offset(left, top),
                end = Offset(left + cornerLength, top),
                strokeWidth = strokeWidth
            )
        }
        90f -> {
            // Top-right
            drawLine(
                color = Color.White,
                start = Offset(left, top),
                end = Offset(left + cornerLength, top),
                strokeWidth = strokeWidth
            )
            drawLine(
                color = Color.White,
                start = Offset(left + cornerLength, top),
                end = Offset(left + cornerLength, top + cornerLength),
                strokeWidth = strokeWidth
            )
        }
        180f -> {
            // Bottom-right
            drawLine(
                color = Color.White,
                start = Offset(left + cornerLength, top),
                end = Offset(left + cornerLength, top + cornerLength),
                strokeWidth = strokeWidth
            )
            drawLine(
                color = Color.White,
                start = Offset(left + cornerLength, top + cornerLength),
                end = Offset(left, top + cornerLength),
                strokeWidth = strokeWidth
            )
        }
        270f -> {
            // Bottom-left
            drawLine(
                color = Color.White,
                start = Offset(left, top),
                end = Offset(left, top + cornerLength),
                strokeWidth = strokeWidth
            )
            drawLine(
                color = Color.White,
                start = Offset(left, top + cornerLength),
                end = Offset(left + cornerLength, top + cornerLength),
                strokeWidth = strokeWidth
            )
        }
    }
}