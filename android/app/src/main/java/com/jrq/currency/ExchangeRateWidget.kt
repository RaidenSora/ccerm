package com.jrq.currency

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.widget.ImageView
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.AsyncTask
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.IdRes
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

/**
 * Implementation of App Widget functionality.
 */
class ExchangeRateWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        val remoteViews = RemoteViews(context.packageName, R.layout.exchange_rate_widget)
        
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.exchange_rate_widget)
            val textval = widgetData.getString("text","Text")
            //views.setTextViewText(R.id.appwidget_text, textval)
            appWidgetManager.updateAppWidget(appWidgetId,views)
            ImageDownloader(context, appWidgetManager, appWidgetId).execute("https://flagsapi.com/US/flat/64.png","https://flagsapi.com/PH/flat/64.png")
        }
    }

    override fun onEnabled(context: Context) {

    }

    override fun onDisabled(context: Context) {

        // Enter relevant functionality for when the last widget is disabled
    }

    private class ImageDownloader(
        private val context: Context,
        private val appWidgetManager: AppWidgetManager,
        private val appWidgetId: Int
    ) : AsyncTask<String, Void, List<Bitmap?>>() {

        override fun doInBackground(vararg urls: String?): List<Bitmap?> {
            return urls.map { url ->
                try {
                    val connection = URL(url).openConnection() as HttpURLConnection
                    connection.doInput = true
                    connection.connect()
                    val input = connection.inputStream
                    BitmapFactory.decodeStream(input)
                } catch (e: Exception) {
                    null
                }
            }
        }

        override fun onPostExecute(result: List<Bitmap?>) {
            val views = RemoteViews(context.packageName, R.layout.exchange_rate_widget)

            result[0]?.let { views.setImageViewBitmap(R.id.baseCurrencyImageView, it) }
            result[1]?.let { views.setImageViewBitmap(R.id.targetCurrencyImageView, it) }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

