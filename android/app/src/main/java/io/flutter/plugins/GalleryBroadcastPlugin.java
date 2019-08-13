package io.flutter.plugins;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import java.io.File;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

public class GalleryBroadcastPlugin implements MethodChannel.MethodCallHandler {
    private static final String TAG = "GalleryBroadcastPlugin";
    private static final String METHOD_CHANNEL_NAME = "com.frost.lotterywinner/gallerybroadcast";
    private static final String BROADCAST_GALLERY_METHOD_NAME = "sendGalleryBroadcast";
    private static final String IMAGE_PATH_ARGUMENT ="imgPath";
    private Context mContext;

    private GalleryBroadcastPlugin(FlutterView flutterView) {
        mContext = flutterView.getContext();
    }

    public static GalleryBroadcastPlugin registerPlugin(FlutterView flutterView) {
        GalleryBroadcastPlugin plugin = new GalleryBroadcastPlugin(flutterView);
        MethodChannel methodChannel = new MethodChannel(flutterView, METHOD_CHANNEL_NAME);
        methodChannel.setMethodCallHandler(plugin);
        return plugin;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (!BROADCAST_GALLERY_METHOD_NAME.equals(methodCall.method)) {
            result.notImplemented();
            return;
        }
        String imagePath = methodCall.argument(IMAGE_PATH_ARGUMENT);
        sendGalleryBroadcast(imagePath);
        result.success(Boolean.TRUE);
    }

    private void sendGalleryBroadcast(String imagePath) {
        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        File file = new File(imagePath);
        Uri contentUri = Uri.fromFile(file);
        intent.setData(contentUri);
        mContext.sendBroadcast(intent);
        Log.e(TAG, "send broadcast from Android GalleryBroadcastPlugin");
    }

    public void destroy() {
        mContext = null;
    }
}
