package com.example.goal_management_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class RoutineWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }

        Thread {
            val baseUrl = readBaseUrl(context)
            if (baseUrl.isNotEmpty()) {
                refreshWidgetData(context, baseUrl)
            }
        }.start()
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_TOGGLE_ROUTINE) {
            val routineId = intent.getIntExtra(EXTRA_ROUTINE_ID, 0)
            val targetComplete = intent.getBooleanExtra(EXTRA_TARGET_COMPLETE, false)
            if (routineId == 0) {
                return
            }

            Thread {
                val baseUrl = readBaseUrl(context)
                if (baseUrl.isEmpty()) {
                    return@Thread
                }

                val toggleUrl = "$baseUrl/routines/$routineId/complete"
                val toggleMethod = if (targetComplete) "POST" else "DELETE"
                val toggleOk = sendRequest(toggleUrl, toggleMethod)
                if (!toggleOk) {
                    return@Thread
                }

                refreshWidgetData(context, baseUrl)
            }.start()
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        private const val prefsName = "RoutineWidgetPreferences"
        private const val flutterPrefsName = "FlutterSharedPreferences"
        private const val summaryKey = "routine_summary"
        private const val updatedAtKey = "routine_last_updated"
        private const val titlePrefix = "routine_title_"
        private const val idPrefix = "routine_id_"
        private const val completedPrefix = "routine_completed_"

        private const val ACTION_TOGGLE_ROUTINE = "com.example.goal_management_app.TOGGLE_ROUTINE"
        private const val EXTRA_ROUTINE_ID = "extra_routine_id"
        private const val EXTRA_TARGET_COMPLETE = "extra_target_complete"

        private fun titleKey(index: Int): String = "$titlePrefix$index"
        private fun idKey(index: Int): String = "$idPrefix$index"
        private fun completedKey(index: Int): String = "$completedPrefix$index"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val compact = isCompact(options)
            val layoutId = if (compact) {
                R.layout.routine_widget_compact
            } else {
                R.layout.routine_widget
            }
            val views = RemoteViews(context.packageName, layoutId)
            val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)

            val summary = prefs.getString(summaryKey, "오늘의 루틴을 불러오는 중...")
            views.setTextViewText(R.id.widget_summary, summary)

            val updatedAt = prefs.getString(updatedAtKey, "")
            views.setTextViewText(R.id.widget_last_updated, updatedAt)

            val maxItems = if (compact) 1 else 3
            for (index in 1..3) {
                val title = prefs.getString(titleKey(index), "") ?: ""
                val routineId = prefs.getInt(idKey(index), 0)
                val completed = prefs.getBoolean(completedKey(index), false)

                val viewId = when (index) {
                    1 -> R.id.widget_item_1
                    2 -> R.id.widget_item_2
                    else -> R.id.widget_item_3
                }

                if (index > maxItems) {
                    views.setViewVisibility(viewId, android.view.View.GONE)
                    continue
                }

                if (title.isEmpty() || routineId == 0) {
                    if (index == 1) {
                        views.setTextViewText(viewId, "루틴이 없습니다")
                        views.setBoolean(viewId, "setChecked", false)
                        views.setBoolean(viewId, "setEnabled", false)
                        views.setViewVisibility(viewId, android.view.View.VISIBLE)
                    } else {
                        views.setViewVisibility(viewId, android.view.View.GONE)
                    }
                } else {
                    views.setViewVisibility(viewId, android.view.View.VISIBLE)
                    views.setBoolean(viewId, "setEnabled", true)
                    views.setTextViewText(viewId, title)
                    views.setBoolean(viewId, "setChecked", completed)

                    val intent = Intent(context, RoutineWidgetProvider::class.java).apply {
                        action = ACTION_TOGGLE_ROUTINE
                        putExtra(EXTRA_ROUTINE_ID, routineId)
                        putExtra(EXTRA_TARGET_COMPLETE, !completed)
                    }

                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        appWidgetId * 10 + index,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(viewId, pendingIntent)
                }
            }

            val openIntent = Intent(context, MainActivity::class.java)
            val openPendingIntent = PendingIntent.getActivity(
                context,
                0,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, openPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun refreshWidgetData(context: Context, baseUrl: String) {
            val routinesUrl = "$baseUrl/routines/today"
            val response = fetchJson(routinesUrl) ?: return
            val routines = parseRoutineList(response)

            val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            val editor = prefs.edit()

            val totalCount = routines.size
            val completedCount = routines.count { it.completed }
            val summary = if (totalCount == 0) {
                "오늘의 루틴 없음"
            } else {
                "완료 $completedCount / 전체 $totalCount"
            }

            editor.putString(summaryKey, summary)
            editor.putString(updatedAtKey, formatUpdatedAt())

            for (index in 1..3) {
                val routine = routines.getOrNull(index - 1)
                if (routine == null) {
                    editor.putString(titleKey(index), "")
                    editor.putInt(idKey(index), 0)
                    editor.putBoolean(completedKey(index), false)
                } else {
                    editor.putString(titleKey(index), routine.title)
                    editor.putInt(idKey(index), routine.id)
                    editor.putBoolean(completedKey(index), routine.completed)
                }
            }

            editor.apply()

            val manager = AppWidgetManager.getInstance(context)
            val widgetIds = manager.getAppWidgetIds(
                ComponentName(context, RoutineWidgetProvider::class.java)
            )
            widgetIds.forEach { appWidgetId ->
                updateAppWidget(context, manager, appWidgetId)
            }
        }

        private fun formatUpdatedAt(): String {
            val formatter = SimpleDateFormat("HH:mm", Locale.KOREA)
            return "업데이트 ${formatter.format(Date())}"
        }

        private fun readBaseUrl(context: Context): String {
            val flutterPrefs = context.getSharedPreferences(flutterPrefsName, Context.MODE_PRIVATE)
            val widgetUrl = flutterPrefs.getString("flutter.widget_base_url", "") ?: ""
            if (widgetUrl.isNotEmpty()) {
                return widgetUrl
            }
            val customUrl = flutterPrefs.getString("flutter.server_url", "") ?: ""
            return customUrl
        }

        private fun isCompact(options: android.os.Bundle): Boolean {
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            return minWidth < 200 || minHeight < 120
        }

        private fun sendRequest(url: String, method: String): Boolean {
            return try {
                val connection = (URL(url).openConnection() as HttpURLConnection).apply {
                    requestMethod = method
                    setRequestProperty("Content-Type", "application/json; charset=UTF-8")
                    connectTimeout = 10000
                    readTimeout = 10000
                }
                if (method == "POST") {
                    connection.doOutput = true
                    connection.outputStream.use { stream ->
                        stream.write("{}".toByteArray())
                    }
                }
                val code = connection.responseCode
                connection.disconnect()
                code in 200..299
            } catch (_: Exception) {
                false
            }
        }

        private fun fetchJson(url: String): String? {
            return try {
                val connection = (URL(url).openConnection() as HttpURLConnection).apply {
                    requestMethod = "GET"
                    connectTimeout = 10000
                    readTimeout = 10000
                }
                val response = connection.inputStream.bufferedReader().use { it.readText() }
                connection.disconnect()
                response
            } catch (_: Exception) {
                null
            }
        }

        private fun parseRoutineList(json: String): List<RoutineSnapshot> {
            val jsonArray = JSONArray(json)
            val routines = mutableListOf<RoutineSnapshot>()
            for (i in 0 until jsonArray.length()) {
                val item = jsonArray.getJSONObject(i)
                val id = item.optInt("id", 0)
                val title = item.optString("title", "")
                val completed = item.optBoolean("completedToday", false)
                if (id != 0 && title.isNotEmpty()) {
                    routines.add(RoutineSnapshot(id, title, completed))
                }
            }
            return routines
        }
    }

    private data class RoutineSnapshot(
        val id: Int,
        val title: String,
        val completed: Boolean
    )
}
