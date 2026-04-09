package com.memozap.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class PantryWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.pantry_widget)

            // Low stock data
            val lowStockCount = widgetData.getInt("low_stock_count", 0)
            val lowStockJson = widgetData.getString("low_stock_items", "[]") ?: "[]"
            val lowStockItems = try {
                val arr = JSONArray(lowStockJson)
                (0 until arr.length()).map { arr.getString(it) }
            } catch (e: Exception) {
                emptyList()
            }

            // Expiring data
            val expiringCount = widgetData.getInt("expiring_count", 0)

            // Pantry health
            val pantryHealth = widgetData.getInt("pantry_health", 100)
            val totalItems = widgetData.getInt("total_items", 0)

            // Update views
            views.setTextViewText(R.id.widget_title, "🏠 המזווה שלי")
            views.setTextViewText(R.id.widget_health, "$pantryHealth% תקין")
            views.setTextViewText(R.id.widget_total, "$totalItems מוצרים")

            if (lowStockCount > 0) {
                val itemsList = lowStockItems.joinToString("\n") { "• $it" }
                views.setTextViewText(R.id.widget_low_stock_label, "⚠️ מלאי נמוך ($lowStockCount)")
                views.setTextViewText(R.id.widget_low_stock_items, itemsList)
            } else {
                views.setTextViewText(R.id.widget_low_stock_label, "✅ הכל במלאי!")
                views.setTextViewText(R.id.widget_low_stock_items, "")
            }

            if (expiringCount > 0) {
                views.setTextViewText(R.id.widget_expiry_label, "⏰ $expiringCount עומדים לפוג")
            } else {
                views.setTextViewText(R.id.widget_expiry_label, "")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
