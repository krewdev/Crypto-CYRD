package com.cypherrelay.vault.network

import com.cypherrelay.vault.BuildConfig
import com.squareup.moshi.JsonClass
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Query
import retrofit2.http.GET
import retrofit2.http.Path
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

    @POST("/wallet/contacts")
    suspend fun setContacts(
        @Query("user_id") userId: String,
        @Body contacts: List<Contact>
    ): Map<String, Any>

    @POST("/wallet/recovery/start")
    suspend fun startRecovery(@Query("user_id") userId: String): Map<String, Any>

    @GET("/pathways/{user_id}")
    suspend fun getPathways(@Path("user_id") userId: String): List<PathwayStatus>

    @POST("/pathways/update")
    suspend fun updatePathway(@Body body: PathwayUpdateRequest): PathwayStatus
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

@JsonClass(generateAdapter = true)
data class Contact(
    val name: String,
    val method: String,
    val value: String
)

@JsonClass(generateAdapter = true)
data class PathwayStatus(
    val pathway_id: String,
    val status: String
)

@JsonClass(generateAdapter = true)
data class PathwayUpdateRequest(
    val user_id: String,
    val pathway_id: String,
    val status: String
)
