package com.cypherrelay.vault.network

import com.cypherrelay.vault.BuildConfig
import com.squareup.moshi.JsonClass
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import java.util.UUID

@JsonClass(generateAdapter = true)
data class RedeemRequest(
    val device_id: String,
    val qr_code: String,
    val chain: String
)

@JsonClass(generateAdapter = true)
data class RedeemResponse(
    val success: Boolean,
    val user_id: String,
    val wallet_address: String?,
    val amount_cyrd: Int,
    val message: String
)

interface RelayApi {
    @POST("/redeem")
    suspend fun redeem(@Body body: RedeemRequest): RedeemResponse
}

object ApiClient {
    val api: RelayApi by lazy {
        Retrofit.Builder()
            .baseUrl(BuildConfig.BASE_URL)
            .addConverterFactory(MoshiConverterFactory.create())
            .build()
            .create(RelayApi::class.java)
    }

    fun defaultDeviceId(): String = UUID.randomUUID().toString()
}
