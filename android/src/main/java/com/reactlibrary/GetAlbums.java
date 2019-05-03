package com.reactlibrary;


import android.content.Context;
import android.database.Cursor;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.RequiresApi;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class GetAlbums extends AsyncTask<Void, Void, Void> {
    private final Context mContext;
    private final Promise mPromise;

    public GetAlbums(Context context, Promise promise) {
        mContext = context;
        mPromise = promise;
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected Void doInBackground(Void... params) {
        WritableArray result = new WritableNativeArray();
        List<WritableMap> AlbumListArray = new ArrayList();
        List<String> AlbumNameArray = new ArrayList<String>();


        final String countColumn = "COUNT(*)";
        final String[] projection = {MediaStore.Images.Media.BUCKET_ID, MediaStore.Images.Media.BUCKET_DISPLAY_NAME, countColumn};

        final String selection = MediaStore.Files.FileColumns.MEDIA_TYPE + " == " + MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE + ") /*";

        try (Cursor albums = mContext.getContentResolver().query(
                MediaStore.Files.getContentUri("external"),
                projection,
                selection,
                null,
                "*/ GROUP BY " + MediaStore.Images.Media.BUCKET_ID +
                        " ORDER BY " + MediaStore.Images.Media.BUCKET_DISPLAY_NAME)) {

            if (albums == null) {
                mPromise.reject("ERROR_UNABLE_TO_LOAD", "Could not get albums. Query returns null.");
            }
            if (albums != null && albums.getCount() > 0) {
                final int bucketIdIndex = albums.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID);
                final int bucketDisplayNameIndex = albums.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
                final int numOfItemsIndex = albums.getColumnIndexOrThrow(countColumn);

                while (albums.moveToNext()) {
                    WritableMap album = Arguments.createMap();
                    album.putString("subType", albums.getString(bucketIdIndex));
                    album.putString("title", albums.getString(bucketDisplayNameIndex));
                    album.putInt("count", albums.getInt(numOfItemsIndex));

                    if (albums.getString(bucketDisplayNameIndex).toLowerCase().equals("camera")) {
                        AlbumListArray.add(0, album);
                        AlbumNameArray.add(0, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else if (albums.getString(bucketDisplayNameIndex).toLowerCase().contains("pictures")) {
                        int index = 1;
                        if (AlbumListArray.size() < index) {
                            index = AlbumListArray.size();
                        }
                        AlbumListArray.add(index, album);
                        AlbumNameArray.add(index, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else if (albums.getString(bucketDisplayNameIndex).toLowerCase().contains("whatsapp")) {
                        int index = 2;
                        if (AlbumListArray.size() < index) {
                            index = AlbumListArray.size();
                        }
                        AlbumListArray.add(index, album);
                        AlbumNameArray.add(index, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else if (albums.getString(bucketDisplayNameIndex).toLowerCase().equals("messenger")) {
                        int index = 3;
                        if (AlbumListArray.size() < index) {
                            index = AlbumListArray.size();
                        }
                        AlbumListArray.add(index, album);
                        AlbumNameArray.add(index, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else if (albums.getString(bucketDisplayNameIndex).toLowerCase().equals("download")) {
                        int index = 4;
                        if (AlbumListArray.size() < index) {
                            index = AlbumListArray.size();
                        }
                        AlbumListArray.add(index, album);
                        AlbumNameArray.add(index, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else if (albums.getString(bucketDisplayNameIndex).toLowerCase().equals("screenshots")) {
                        int index = 5;
                        if (AlbumListArray.size() < index) {
                            index = AlbumListArray.size();
                        }
                        AlbumListArray.add(index, album);
                        AlbumNameArray.add(index, albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    } else {
                        AlbumListArray.add(album);
                        AlbumNameArray.add(albums.getString(bucketDisplayNameIndex) + " (" + albums.getInt(numOfItemsIndex) + ")");
                    }

                }

                WritableArray AlbumList = Arguments.createArray();
                for (WritableMap episode : AlbumListArray) {
                    WritableMap Alb = new WritableNativeMap();
                    Alb.putString("title", episode.getString("title"));
                    Alb.putString("subType", episode.getString("subType"));
                    Alb.putInt("count", episode.getInt("count"));
                    AlbumList.pushMap(Alb);
                }

                String[] returnArray2 = new String[AlbumNameArray.size()];
                returnArray2 = AlbumNameArray.toArray(returnArray2);
                WritableArray AlbumName = Arguments.createArray();
                for (int i = 0; i < returnArray2.length; i++) {
                    AlbumName.pushString(returnArray2[i]);
                }

                result.pushArray(AlbumList);
                result.pushArray(AlbumName);
                mPromise.resolve(result);
            } else {
                mPromise.resolve(null);
            }
        } catch (SecurityException e) {
            mPromise.reject("ERROR_UNABLE_TO_LOAD_PERMISSION",
                    "Could not get albums: need READ_EXTERNAL_STORAGE permission.", e);
        }
        return null;
    }
}
