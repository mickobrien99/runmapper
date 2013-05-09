package com.mick.helpers;

import java.sql.Timestamp;
import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Log;

import com.mick.model.DBAdapter;
import com.mick.model.RoutePoints;

public class PointHelper {
	public static ArrayList<RoutePoints> getPoints(Context context,String routeId) {
		ArrayList<RoutePoints> points = new ArrayList<RoutePoints>();
		DBAdapter dbAdapter = null;

		try {
			dbAdapter = DBAdapter.getDBAdapterInstance(context);
		} catch(Exception e) {
		}

		try {
			dbAdapter.createDataBase();
		} catch (Exception e) {
		}

		try {
			dbAdapter.openDataBase();		
		} catch(Exception e) {
		}

		String query="SELECT * FROM RoutePoints where runId=?;";
		Cursor cursor = null;

		try {
			cursor = dbAdapter.selectRecordsFromDB(query,new  String[]{routeId});

			if (cursor != null && cursor.moveToFirst()) 
			{
				while (cursor.isAfterLast() == false) 
				{
					RoutePoints point = new RoutePoints();

					try 
					{
						point.setId(cursor.getInt(0));
						point.setLatitude(cursor.getDouble(1));
						point.setLongitude(cursor.getDouble(2));
						point.setAltitude(cursor.getDouble(3));
						point.setRunId(cursor.getInt(4));

						points.add(point);
						cursor.moveToNext();
					} catch(Exception e) {
					}
				}//end of while
			} else {
				RoutePoints point = new RoutePoints();

				point.setId(0);
				point.setLatitude(0.00);
				point.setLongitude(0.00);
				point.setAltitude(0.00);
				point.setRunId(0);

				points.add(point);
			}
		} catch(Exception e) {
		}

		try {
			cursor.close();
		} catch(Exception e) {
		}

		try {
			dbAdapter.close();			
		} catch(Exception e) {
		}

		return points;
	}

	public static Boolean addPointToRouteToDb(Context context, RoutePoints routePoint) {
		Boolean blnResult = false;
		java.util.Date today = new java.util.Date();
		Timestamp currentTimestamp = new java.sql.Timestamp(today.getTime());

		ContentValues initialValues = new ContentValues();
		DBAdapter dbAdapter = null;

		try {
			dbAdapter = DBAdapter.getDBAdapterInstance(context);
		} catch(Exception e) {
		}
		
		try {
			dbAdapter.createDataBase();
		} catch (Exception e) {
		}

		try {
			dbAdapter.openDataBase();		
		} catch(Exception e) {
		}
		
		initialValues.put("latitude", routePoint.getLatitude());
		initialValues.put("longitude", routePoint.getLongitude());
		initialValues.put("altitude", routePoint.getAltitude());
		initialValues.put("pointTime", routePoint.getPointTime());
		initialValues.put("runId", routePoint.getRunId());

		try{
			long n = dbAdapter.insertRecordsInDB("RoutePoints", null, initialValues);				
			blnResult = true;
		} catch(Exception e) {
		}

		try{
			dbAdapter.close();
		} catch(Exception e) {
			Log.d("***error" + e.toString(), e.getMessage());
		}

		return blnResult;
	}
}