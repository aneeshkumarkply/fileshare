package com.tripleafoodies.fileshare

import android.content.Intent
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory


class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        java.lang.Thread.sleep(1000);
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "listTile", ListTileNativeAdFactory(context))
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
        super.onCreate(savedInstanceState)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }

}
