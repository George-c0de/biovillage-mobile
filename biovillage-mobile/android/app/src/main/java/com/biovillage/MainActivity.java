package com.biovillage;

import io.flutter.embedding.android.FlutterActivity;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    MapKitFactory.setApiKey("eb9bcbfa-1b96-4098-8b64-fd120192b6c7");
    super.configureFlutterEngine(flutterEngine);
  }
}