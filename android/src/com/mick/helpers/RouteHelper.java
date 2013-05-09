package com.mick.helpers;

import java.sql.Timestamp;
import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.util.Log;

import com.mick.model.DBAdapter;
import com.mick.model.Runs;

public class RouteHelper {
	public static ArrayList<Runs> getRoutes(Context context) {
		ArrayList<Runs> routes = new ArrayList<Runs>();
		DBAdapter dbAdapter = null;

		try {
			dbAdapter = DBAdapter.getDBAdapterInstance(context);
		} catch(Exception e){
			String str = e.toString();
		}

		try {
			dbAdapter.createDataBase();
		} catch (Exception e) {
			String str = e.toString();
		}

		try {
			dbAdapter.openDataBase();		
		} catch(Exception e) {
			String str = e.toString();
		}

		String query = "SELECT * FROM Runs";
		Cursor cursor = null;

		try {
			cursor = dbAdapter.selectRecordsFromDB(query,null);

			if (cursor != null && cursor.moveToFirst())
			{
				while (cursor.isAfterLast() == false) 
				{
					Runs runs = new Runs();

					try 
					{
						runs.setId(cursor.getInt(0));
						runs.setStartAddress(cursor.getString(1));
						runs.setEndAddress(cursor.getString(2));
						runs.setDuration(cursor.getString(3));		
						runs.setDistance(cursor.getString(4));
						runs.setStartTimestamp(cursor.getString(5));

						routes.add(runs);
						cursor.moveToNext();
					} catch(Exception e) {
					}
				}//end of while
			} else {
				Runs runs = new Runs();

				runs.setId(0);
				runs.setStartAddress("No Start Address");		
				runs.setEndAddress("No End Address");		
				runs.setDuration("0");		
				runs.setDistance("0");
				runs.setStartTimestamp("");

				routes.add(runs);
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

		return routes;
	}

	public static long addRouteToDb(Context context, Runs run) {
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

		try{
			dbAdapter.openDataBase();		
		} catch(Exception e) {
		}

		initialValues.put("startAddress", run.getStartAddress());
		initialValues.put("endAddress", run.getEndAddress());
		initialValues.put("duration", run.getDuration());
		initialValues.put("distance", run.getDistance());
		initialValues.put("startTimestamp", run.getStartTimestamp());

		long n = 0;

		try {
			n = dbAdapter.insertRecordsInDB("Runs", null, initialValues);
		} catch(Exception e) {
		}

		try {
			dbAdapter.close();
		} catch(Exception e) {
			Log.d("***error" + e.toString(), e.getMessage());
		}

		return n;
	}

	public static Boolean deleteRoute(Context context, String id) {
		Boolean result = false;
		
		String[] strDeleteAll = new String[1];
		strDeleteAll[0] = "";
		//delete all offers this can be optimized later
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

		long n=0;
		try{
			String[] strArray={id};
			n = dbAdapter.deleteRecordInDB("Runs", "id = ?", strArray);
			n = dbAdapter.deleteRecordInDB("RoutePoints", "runId = ?", strArray);
			Log.v("delete all routes and related records from local db", n + " rows effected");
			
			result = true;
		} catch(Exception e2) {
		}

		try {
			dbAdapter.close();
		} catch(Exception e3) {
		}
		
		return result;
	}
}