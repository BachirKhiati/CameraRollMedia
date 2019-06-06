
package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import android.media.ExifInterface;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.BaseColumns;
import android.provider.MediaStore;
import android.provider.MediaStore.Images;
import android.text.TextUtils;
import android.util.Log;
import android.content.ContentResolver;
import android.widget.ImageView;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.GuardedAsyncTask;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.ReactConstants;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Nullable;

public class RNCameraRollMediaModule extends ReactContextBaseJavaModule {

    public static final String NAME = "RNCameraRollMedia";

    private static final String ERROR_UNABLE_TO_LOAD = "E_UNABLE_TO_LOAD";
    private static final String ERROR_UNABLE_TO_LOAD_PERMISSION = "E_UNABLE_TO_LOAD_PERMISSION";
    private static final String ERROR_UNABLE_TO_SAVE = "E_UNABLE_TO_SAVE";
    private static final String ERROR_UNABLE_TO_FILTER = "E_UNABLE_TO_FILTER";

    private static final String ASSET_TYPE_PHOTOS = "Photos";
    private static final String ASSET_TYPE_VIDEOS = "Videos";

    private static final String[] PROJECTION = {
            Images.Media._ID,
            Images.Media.MIME_TYPE,
            Images.Media.BUCKET_DISPLAY_NAME,
            Images.Media.DATE_TAKEN,
            MediaStore.MediaColumns.WIDTH,
            MediaStore.MediaColumns.HEIGHT,
            Images.Media.LONGITUDE,
            Images.Media.LATITUDE,
            MediaStore.MediaColumns.DATA
    };

    private static final String SELECTION_BUCKET = Images.Media.BUCKET_DISPLAY_NAME + " = ?";
    private static final String SELECTION_DATE_TAKEN = Images.Media.DATE_TAKEN + " < ?";
    private static final String SELECTION_DATE_TAKEN_BEFORE = Images.Media.DATE_TAKEN + " > ?";


    private final ReactApplicationContext reactContext;

    public RNCameraRollMediaModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return NAME;
    }


    @ReactMethod
    public void fetchAssets(final ReadableMap params, final Promise promise) {
        String first = params.hasKey("first") ? params.getString("first") : null;
        int count = params.hasKey("count") ? params.getInt("count") : 120;
        String after = params.hasKey("after") ? params.getString("after") : null;
        String assetType = params.hasKey("assetType") ? params.getString("assetType") : ASSET_TYPE_PHOTOS;
        String albumName = params.hasKey("title") ? params.getString("title") : null;
        new GetMediaTask(
                getReactApplicationContext(),
                albumName,
                count,
                first,
                after,
                assetType,
                promise)
                .executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    @ReactMethod
    public void getSize(String uri, final Promise promise) {
        try {
            Uri u = Uri.parse(uri);
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;

            int height = 0;
            int width = 0;

            if (uri.startsWith("file://")) {
                BitmapFactory.decodeFile(u.getPath(), options);
                int orientation= CheckRotation(u);
                if(orientation == 90 || orientation == 270){
                    height = options.outWidth;
                    width = options.outHeight;
                } else {
                    height = options.outHeight;
                    width = options.outWidth;
                }

            } else {
                URL url = new URL(uri);
                Bitmap bitmap = BitmapFactory.decodeStream((InputStream) url.getContent());
                int orientation= CheckRotation(u);
                if(orientation == 90 || orientation == 270){
                    height = bitmap.getWidth();
                    width = bitmap.getHeight();
                } else {
                    height = bitmap.getHeight();
                    width = bitmap.getWidth();
                }

            }




            WritableMap map = Arguments.createMap();

            map.putInt("height", height);
            map.putInt("width", width);

            promise.resolve(map);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getAlbums(final String type, final Promise promise) {
        new GetAlbums(type, getReactApplicationContext(), promise).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }



    private static class GetMediaTask extends GuardedAsyncTask<Void, Void> {
        private final Context mContext;
        private final String mAlbumName;
        private final int mCount;
        private final @Nullable
        String mFirst;
        String mAfter;
        private final Promise mPromise;
        private final String mAssetType;

        private GetMediaTask(
                ReactContext context,
                String  AlbumName,
                int count,
                @Nullable String first,
                @Nullable String after,
                String assetType,
                Promise promise) {
            super(context);
            mContext = context;
            mAlbumName = AlbumName;
            mCount = count;
            mFirst = first;
            mAfter = after;
            mPromise = promise;
            mAssetType = assetType;
        }

        @Override
        protected void doInBackgroundGuarded(Void... params) {
            StringBuilder selection = new StringBuilder("1");
            List<String> selectionArgs = new ArrayList<>();
            if (!TextUtils.isEmpty(mAlbumName)) {
                selection.append(" AND " + SELECTION_BUCKET);
                selectionArgs.add(mAlbumName);
            }
            if (!TextUtils.isEmpty(mFirst)) {
                selection.append(" AND " + SELECTION_DATE_TAKEN_BEFORE);
                selectionArgs.add(mFirst);
            } else if (!TextUtils.isEmpty(mAfter)) {
                selection.append(" AND " + SELECTION_DATE_TAKEN);
                selectionArgs.add(mAfter);
            }

            if (mAssetType.equals(ASSET_TYPE_PHOTOS)) {
                selection.append(" AND " + MediaStore.Files.FileColumns.MEDIA_TYPE + " = "
                        + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE);
            } else if (mAssetType.equals(ASSET_TYPE_VIDEOS)) {
                selection.append(" AND " + MediaStore.Files.FileColumns.MEDIA_TYPE + " = "
                        + MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO);
            } else {
                mPromise.reject(
                        ERROR_UNABLE_TO_FILTER,
                        "Invalid filter option: '" + mAssetType + "'. Expected one of '"
                                + ASSET_TYPE_PHOTOS + "', '" + ASSET_TYPE_VIDEOS + "' or '"
                );
                return;
            }
            WritableMap response = new WritableNativeMap();
            ContentResolver resolver = mContext.getContentResolver();
            // using LIMIT in the sortOrder is not explicitly supported by the SDK (which does not support
            // setting a limit at all), but it works because this specific ContentProvider is backed by
            // an SQLite DB and forwards parameters to it without doing any parsing / validation.
            try {
                Cursor media = resolver.query(
                        MediaStore.Files.getContentUri("external"),
                        PROJECTION,
                        selection.toString(),
                        selectionArgs.toArray(new String[selectionArgs.size()]),
                        Images.Media.DATE_TAKEN + " DESC, " + Images.Media.DATE_MODIFIED + " DESC LIMIT " +
                                (mCount + 1)); // set LIMIT to first + 1 so that we know how to populate page_info
                if (media == null) {
                    mPromise.reject(ERROR_UNABLE_TO_LOAD, "Could not get media");
                } else {
                    try {
                        putAssets(resolver, media, response, mCount);
                        putLimits(media, response, mCount);
                    } finally {
                        media.close();
                        mPromise.resolve(response);
                    }
                }
            } catch (SecurityException e) {
                mPromise.reject(
                        ERROR_UNABLE_TO_LOAD_PERMISSION,
                        "Could not get media: need READ_EXTERNAL_STORAGE permission",
                        e);
            }
        }
    }

    private static void putLimits(Cursor media, WritableMap response, int limit) {
        response.putBoolean("noMore", limit >= media.getCount());
        if (media.getCount() > 0) {
            media.moveToPosition(0);
            response.putString(
                    "firstAssetUnix",
                    media.getString(media.getColumnIndex(Images.Media.DATE_TAKEN)));
            if(media.getCount() > limit){
                media.moveToPosition(limit - 1);
            } else {
                media.moveToPosition(media.getCount() - 1);
            }
            response.putString(
                    "lastAssetUnix",
                    media.getString(media.getColumnIndex(Images.Media.DATE_TAKEN)));

        }

    }

    private static void putAssets(
            ContentResolver resolver,
            Cursor media,
            WritableMap response,
            int limit) {
        WritableArray edges = new WritableNativeArray();
        media.moveToFirst();
        int idIndex = media.getColumnIndex(Images.Media._ID);
        int mimeTypeIndex = media.getColumnIndex(Images.Media.MIME_TYPE);
        int groupNameIndex = media.getColumnIndex(Images.Media.BUCKET_DISPLAY_NAME);
        int dateTakenIndex = media.getColumnIndex(Images.Media.DATE_TAKEN);
        int widthIndex = media.getColumnIndex(MediaStore.MediaColumns.WIDTH);
        int heightIndex = media.getColumnIndex(MediaStore.MediaColumns.HEIGHT);
        int longitudeIndex = media.getColumnIndex(Images.Media.LONGITUDE);
        int latitudeIndex = media.getColumnIndex(Images.Media.LATITUDE);
        int dataIndex = media.getColumnIndex(MediaStore.MediaColumns.DATA);
        for (int i = 0; i < limit && !media.isAfterLast(); i++) {
            WritableMap node = new WritableNativeMap();
            boolean imageInfoSuccess =
                    putImageInfo(resolver, media, node, idIndex, widthIndex, heightIndex, dataIndex);
            if (imageInfoSuccess) {
                putBasicNodeInfo(media, node, mimeTypeIndex, groupNameIndex, dateTakenIndex);
                putLocationInfo(media, node, longitudeIndex, latitudeIndex);
                edges.pushMap(node);
            } else {
                // we skipped an image because we couldn't get its details (e.g. width/height), so we
                // decrement i in order to correctly reach the limit, if the cursor has enough rows
                i--;
            }
            media.moveToNext();
        }
        response.putArray("assets", edges);
    }

    private static void putBasicNodeInfo(
            Cursor media,
            WritableMap node,
            int mimeTypeIndex,
            int groupNameIndex,
            int dateTakenIndex) {
        node.putString("type", media.getString(mimeTypeIndex));
        node.putString("group_name", media.getString(groupNameIndex));
        node.putDouble("created", media.getLong(dateTakenIndex) / 1000d);
    }

    private static boolean putImageInfo(
            ContentResolver resolver,
            Cursor media,
            WritableMap node,
            int idIndex,
            int widthIndex,
            int heightIndex,
            int dataIndex
    ) {
        String thumbnailURL = null;
        Uri photoUri = Uri.parse("file://" + media.getString(dataIndex));
        int id = media.getInt(media.getColumnIndex(MediaStore.MediaColumns._ID));
        Uri baseUri = Uri.parse("content://media/external/images/media/" + id);
        node.putString("uri", photoUri.toString());
        node.putString("baseUri", baseUri.toString());
        float width = media.getInt(widthIndex);
        float height = media.getInt(heightIndex);
        String mimeType = URLConnection.guessContentTypeFromName(photoUri.toString());
        if (mimeType != null && !mimeType.startsWith("video")) {
            thumbnailURL = getThumbnailPhoto(resolver, id);
            if (thumbnailURL != null) {
                Uri thumbnail = Uri.parse("file://" + thumbnailURL);
                node.putString("thumbnail", thumbnail.toString());
            }
        }
        if (mimeType != null
                && mimeType.startsWith("video")) {
            try {
                AssetFileDescriptor photoDescriptor = resolver.openAssetFileDescriptor(photoUri, "r");
                MediaMetadataRetriever retriever = new MediaMetadataRetriever();
                retriever.setDataSource(photoDescriptor.getFileDescriptor());
                try {
                    if (width <= 0 || height <= 0) {
                        width =
                                Integer.parseInt(
                                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
                        height =
                                Integer.parseInt(
                                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
                    }
                    int timeInMillisec =
                            Integer.parseInt(
                                    retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                    int playableDuration = timeInMillisec / 1000;
                    node.putInt("duration", playableDuration);
//                        String videoThumbnailURL = getThumbnailVideo(resolver, photoUri, id);
                    String videoThumbnailURL = getThumbnailVideo(resolver, id);
                    if (videoThumbnailURL != null) {
                        Uri thumbnail = Uri.parse(videoThumbnailURL);
                        node.putString("thumbnail", thumbnail.toString());
                    }
                } catch (NumberFormatException e) {
                    FLog.e(
                            ReactConstants.TAG,
                            "Number format exception occurred while trying to fetch video metadata for "
                                    + photoUri.toString(),
                            e);
                    return false;
                } finally {
                    retriever.release();
                    photoDescriptor.close();
                }
            } catch (Exception e) {
                FLog.e(ReactConstants.TAG, "Could not get video metadata for " + photoUri.toString(), e);
                return false;
            }
        }

        if (width <= 0 || height <= 0) {
            try {
                AssetFileDescriptor photoDescriptor = resolver.openAssetFileDescriptor(photoUri, "r");
                BitmapFactory.Options options = new BitmapFactory.Options();
                // Set inJustDecodeBounds to true so we don't actually load the Bitmap, but only get its
                // dimensions instead.
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeFileDescriptor(photoDescriptor.getFileDescriptor(), null, options);
                width = options.outWidth;
                height = options.outHeight;
                photoDescriptor.close();
            } catch (IOException e) {
                FLog.e(ReactConstants.TAG, "Could not get width/height for " + photoUri.toString(), e);
                return false;
            }
        }
        node.putDouble("width", width);
        node.putDouble("height", height);

        return true;
    }

    private static void putLocationInfo(
            Cursor media,
            WritableMap node,
            int longitudeIndex,
            int latitudeIndex) {
        double longitude = media.getDouble(longitudeIndex);
        double latitude = media.getDouble(latitudeIndex);
        if (longitude > 0 || latitude > 0) {
            WritableMap location = new WritableNativeMap();
            location.putDouble("longitude", longitude);
            location.putDouble("latitude", latitude);
            node.putMap("location", location);
        }
    }

    private static final String[] THUMBNAIL_PROJECTION = new String[]{
            MediaStore.Images.Thumbnails.DATA
    };


    static String getThumbnailVideo(ContentResolver resolver, long videoId) {
        String path = null;
        String[] proj = {MediaStore.Video.Thumbnails._ID};
        Cursor c = resolver.query(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI,
                proj, MediaStore.Video.Thumbnails.VIDEO_ID + "=" + videoId,
                null, null);
        if (c != null && c.getCount() > 0) {
            try {
                c.moveToFirst();
                Uri thumb = Uri.withAppendedPath(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI, c.getLong(0) + "");
                path = thumb.toString();
            } catch (java.lang.SecurityException ex) {
                Log.d("DEBUG", "Error");
            }
        }
        if (path == null) {
            path = getThumbnailVideo2(resolver, videoId);
        }
        return path;
    }

    static String getThumbnailPhoto(ContentResolver resolver, long id) {
        String path = null;
        Cursor cursor = MediaStore.Images.Thumbnails.queryMiniThumbnail(
                resolver,
                id,
                MediaStore.Images.Thumbnails.MICRO_KIND,
                THUMBNAIL_PROJECTION);
        if (cursor != null && cursor.getCount() == 0) {
            cursor = MediaStore.Images.Thumbnails.queryMiniThumbnail(
                    resolver,
                    id,
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    THUMBNAIL_PROJECTION);
        }
        if (cursor != null && cursor.getCount() > 0) {
            cursor.moveToFirst();
            path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
        }

        return path;
    }

    static String getThumbnailVideo2(ContentResolver resolver, long id) {
        String path = null;
        Bitmap video = null;
        BitmapFactory.Options options = new BitmapFactory.Options();
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        options.inSampleSize = 1;
        try {
            video = MediaStore.Video.Thumbnails.getThumbnail(resolver, id, MediaStore.Video.Thumbnails.MICRO_KIND, options);
            if (video != null) {
//                video.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
                path = Images.Media.insertImage(resolver, video, String.valueOf(id), null);
            }
        } catch (java.lang.SecurityException ex) {
            ex.printStackTrace();
            Log.d("DEBUG", "Error");
            return null;
        }
        return path;
    }

    static int CheckRotation(Uri uri){
        try {
                ExifInterface ei = new ExifInterface(uri.getPath());
                return getOrientation(ei);
        } catch (Exception ignored) { }
        return 0;
    }


    public static int getOrientation(ExifInterface exif) {
        int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
        switch (orientation) {
            case ExifInterface.ORIENTATION_ROTATE_90:
                return 90;
            case ExifInterface.ORIENTATION_ROTATE_180:
                return 180;
            case ExifInterface.ORIENTATION_ROTATE_270:
                return 270;
            default:
                return 0;
        }
    }

}