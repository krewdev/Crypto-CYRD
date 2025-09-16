package com.cypherrelay.vault

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import androidx.lifecycle.ViewModel
import com.cypherrelay.vault.network.ApiClient
import com.cypherrelay.vault.network.RedeemRequest
import com.cypherrelay.vault.qr.QRScannerView

class ScanViewModel: ViewModel() {
    var loading by mutableStateOf(false)
    var error by mutableStateOf<String?>(null)
    var scanned by mutableStateOf<String?>(null)

    fun onScanned(code: String, onSuccess: () -> Unit) {
        if (loading) return
        scanned = code
        viewModelScope.launch {
            try {
                loading = true
                error = null
                val req = RedeemRequest(
                    device_id = ApiClient.defaultDeviceId(),
                    qr_code = code,
                    chain = "polygon"
                )
                ApiClient.api.redeem(req)
                onSuccess()
            } catch (t: Throwable) {
                error = t.message
            } finally {
                loading = false
            }
        }
    }
}

@Composable
fun ScanScreen(onRedeemed: () -> Unit) {
    val vm = remember { ScanViewModel() }
    Column(Modifier.fillMaxSize()) {
        Box(Modifier.weight(1f)) {
            QRScannerView(modifier = Modifier.fillMaxSize()) { code ->
                vm.onScanned(code, onRedeemed)
            }
        }
        Column(Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Scan Your Card", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            if (vm.loading) { Text("Redeeming...") }
            if (vm.error != null) { Text(vm.error!!, color = MaterialTheme.colorScheme.error) }
            TextButton(onClick = {}) { Text("What is this?") }
        }
    }
}

@Composable
fun VaultScreen(onOpenPathways: () -> Unit, onOpenContacts: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(24.dp)) {
        Text("$25.00 USD", style = MaterialTheme.typography.displaySmall, fontWeight = FontWeight.Bold)
        Text("25 CYRD", style = MaterialTheme.typography.bodyLarge)
        Spacer(Modifier.height(24.dp))
        Text("History", style = MaterialTheme.typography.titleMedium)
        Spacer(Modifier.height(8.dp))
        Text("Received from Cypher Card")
        Spacer(Modifier.height(24.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Button(onClick = onOpenPathways, enabled = true) { Text("Send (Locked)") }
            OutlinedButton(onClick = onOpenPathways) { Text("Swap (Locked)") }
            OutlinedButton(onClick = onOpenPathways) { Text("Explore (Locked)") }
        }
        Spacer(Modifier.height(16.dp))
        OutlinedButton(onClick = onOpenContacts) { Text("Trusted Contacts") }
    }
}

@Composable
fun PathwaysScreen(onDone: () -> Unit) {
    Column(Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center, horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Unlock 'Send'", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(12.dp))
        Text("Crypto addresses are like email, but for money. Always double-check them!")
        Spacer(Modifier.height(24.dp))
        Button(onClick = onDone) { Text("Answer: Double-check the address") }
    }
}

@Composable
fun ContactsScreen(onDone: () -> Unit) {
    var name by remember { mutableStateOf("") }
    var method by remember { mutableStateOf("sms") }
    var value by remember { mutableStateOf("") }
    var submitting by remember { mutableStateOf(false) }
    var feedback by remember { mutableStateOf<String?>(null) }

    Column(Modifier.fillMaxSize().padding(24.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Trusted Contacts", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        OutlinedTextField(value = name, onValueChange = { name = it }, label = { Text("Name") })
        OutlinedTextField(value = value, onValueChange = { value = it }, label = { Text("Phone or Email") })
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            FilterChip(selected = method == "sms", onClick = { method = "sms" }, label = { Text("SMS") })
            FilterChip(selected = method == "email", onClick = { method = "email" }, label = { Text("Email") })
        }
        Button(enabled = !submitting, onClick = {
            submitting = true
            feedback = null
            val userId = ApiClient.defaultDeviceId()
            val contacts = listOf(com.cypherrelay.vault.network.Contact(name = name, method = method, value = value))
            kotlinx.coroutines.GlobalScope.launch {
                try {
                    ApiClient.api.setContacts(userId, contacts)
                    feedback = "Saved"
                } catch (t: Throwable) {
                    feedback = t.message
                } finally {
                    submitting = false
                }
            }
        }) { Text(if (submitting) "Saving..." else "Save") }
        OutlinedButton(onClick = onDone) { Text("Done") }
        if (feedback != null) Text(feedback!!)
    }
}
