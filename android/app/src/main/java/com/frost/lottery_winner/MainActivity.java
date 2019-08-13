package com.frost.lottery_winner;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GalleryBroadcastPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private GalleryBroadcastPlugin mGalleryBroadcastPlugin;
    private static final String METHOD_CHANNEL_NAME = "com.frost.lotterywinner/gallerybroadcast";
    private static final String BROADCAST_GALLERY_METHOD_NAME = "sendGalleryBroadcast";
    private static final String IMAGE_PATH_ARGUMENT = "imgPath";
    private static final int WRITE_PERMISSION_REQ_CODE = 1024;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        MethodChannel.MethodCallHandler handler = (methodCall, result) -> {
            if (!BROADCAST_GALLERY_METHOD_NAME.equals(methodCall.method)) {
                result.notImplemented();
                return;
            }
            String imagePath = methodCall.argument(IMAGE_PATH_ARGUMENT);
            new Thread(() -> {
                boolean ret = sendGalleryBroadcast(imagePath);
                runOnUiThread(()-> {
                    if (ret) {
                        result.success(Boolean.TRUE);
                    } else {
                        result.error("Failed to save image", null, null);
                    }
                });
            }).start();
        };
        new MethodChannel(getFlutterView(), METHOD_CHANNEL_NAME).setMethodCallHandler(handler);
//    mGalleryBroadcastPlugin = GalleryBroadcastPlugin.registerPlugin(getFlutterView());
    }

    private boolean copyFile(File src, File dest) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, WRITE_PERMISSION_REQ_CODE);
                return false;
            }
        }
        try {
            Files.copy(src.toPath(), dest.toPath());
        } catch (IOException e) {
            Log.e("MainActivity", "Copy file failed");
            return false;
        }
        return true;
    }

    public boolean sendGalleryBroadcast(String imagePath) {
        File srcImage = new File(imagePath);
        File extDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
        File destFile = new File(extDir, srcImage.getName());
        if (copyFile(srcImage, destFile)) {
            Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            File file = new File(imagePath);
            Uri contentUri = Uri.fromFile(file);
            intent.setData(contentUri);
            sendBroadcast(intent);
            Log.e("MainActivity", "send broadcast from Android MainActivity");
            return true;
        }
        return false;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == WRITE_PERMISSION_REQ_CODE) {
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "你拒绝你🐴呢", Toast.LENGTH_SHORT).show();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
//    mGalleryBroadcastPlugin.destroy();
    }
}
