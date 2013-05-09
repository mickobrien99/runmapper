package com.mick.runmapper;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.TimeZone;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import com.mick.helpers.RouteHelper;
import com.mick.helpers.PointHelper;
import com.mick.model.RoutePoints;
import com.mick.model.Runs;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.format.DateFormat;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.Toast;
import android.graphics.Color;

public class TrackActivity extends FragmentActivity implements OnClickListener,GoogleMap.OnMyLocationChangeListener {
	GoogleMap googleMap;
	LocationManager locationManager;
	String provider;
	ArrayList<RoutePoints> arrRoutePoints;
	ArrayList<LatLng> arrLatLng;
	Polyline polyline;
	private ImageButton btnStart;
	private Boolean blnStarted = false;
	private ProgressDialog pDialog;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.track);
		
		btnStart = (ImageButton)findViewById(R.id.btnStart);
		btnStart.setOnClickListener(this);
		
		if(arrRoutePoints != null)
		{
			System.out.println(arrRoutePoints.toString());
		} else {
			System.out.println("arrRoutePoints is null");
		}
		
		if(googleMap != null)
		{
            // Enabling MyLocation Layer of Google Map
            googleMap.setMyLocationEnabled(true);
            
			drawPolyline();
		}
	}
	
	public void startRun() {
        // Getting Google Play availability status
        int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getBaseContext());
 
        // Showing status
        if(status!=ConnectionResult.SUCCESS){ // Google Play Services are not available
            int requestCode = 10;
            Dialog dialog = GooglePlayServicesUtil.getErrorDialog(status, this, requestCode);
            dialog.show();
        } else {    // Google Play Services are available
            // Getting reference to the SupportMapFragment of activity_main.xml
            SupportMapFragment fm = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
 
            // Getting GoogleMap object from the fragment
            googleMap = fm.getMap();
 
            // Enabling MyLocation Layer of Google Map
            googleMap.setMyLocationEnabled(true);
 
            // Setting event handler for location change
            googleMap.setOnMyLocationChangeListener(this);
        }
        
        btnStart.setImageResource(R.drawable.stop_sign_octagon);
        blnStarted = true;
        //btnStop.setVisibility(View.VISIBLE);
	}
	
	public void stopRun() {
		//create a new run instance and save it along with the route points
		//pDialog;
		//calculate distance
		double distance = 0;
		if(arrRoutePoints.size() > 1)
		{
			for(int i = 0; i < arrRoutePoints.size()-1; i++) {
				RoutePoints point = arrRoutePoints.get(i);
				RoutePoints nextPoint = arrRoutePoints.get(i+1);

				Location loc = new Location(USER_SERVICE);
				loc.setLatitude(point.getLatitude());
				loc.setLongitude(point.getLongitude());
				Location nextLoc = new Location(USER_SERVICE);
				nextLoc.setLatitude(nextPoint.getLatitude());
				nextLoc.setLongitude(nextPoint.getLongitude());

				distance = distance + loc.distanceTo(nextLoc);
			}
		}
		//calculate duration
		RoutePoints firstPoint = arrRoutePoints.get(0);
		RoutePoints lastPoint = arrRoutePoints.get(arrRoutePoints.size()-1);
		
		long duration = lastPoint.getPointTime() - firstPoint.getPointTime();
		//Date difference = new Date(duration);
		SimpleDateFormat datePattern =  new SimpleDateFormat ("HH:mm");
		datePattern.setTimeZone(TimeZone.getTimeZone("GMT"));
		String strDuration = datePattern.format(new Date(duration));

//		Calendar calendar = GregorianCalendar.getInstance();
//		calendar.setTime(difference);
//		String strDuration = String.valueOf(calendar.get(Calendar.HOUR_OF_DAY)) + ":" + String.valueOf(calendar.get(Calendar.MINUTE));

		Runs run = new Runs();
		run.setDistance(String.format("%.2f",distance/1000));
		run.setDuration(String.valueOf(strDuration));

		Date startDate = new Date(firstPoint.getPointTime());
		SimpleDateFormat s = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		String startDateFormat = s.format(startDate);
		
		run.setStartTimestamp(startDateFormat);
		
		Geocoder startAddressGeoCoder = new Geocoder(getApplicationContext());
		List<Address> startAddressMatches = null;
		try {
			startAddressMatches = startAddressGeoCoder.getFromLocation(firstPoint.getLatitude(), firstPoint.getLongitude(), 1);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Address startAddress = (startAddressMatches.isEmpty() ? null : startAddressMatches.get(0));

		String strStartAddress = startAddress.getAddressLine(0);
		
		for(int i = 1; i < startAddress.getMaxAddressLineIndex(); i++) {
			strStartAddress = strStartAddress + ", " + startAddress.getAddressLine(i);
		}

		run.setStartAddress(strStartAddress);
		
		Geocoder endAddressGeoCoder = new Geocoder(getApplicationContext());
		List<Address> endAddressMatches = null;
		try {
			endAddressMatches = endAddressGeoCoder.getFromLocation(lastPoint.getLatitude(), lastPoint.getLongitude(), 1);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Address endAddress = (endAddressMatches.isEmpty() ? null : endAddressMatches.get(0));

		String strEndAddress = endAddress.getAddressLine(0);
		
		for(int i = 1; i < endAddress.getMaxAddressLineIndex(); i++) {
			strEndAddress = strEndAddress + ", " + endAddress.getAddressLine(i);
		}
		
		run.setEndAddress(strEndAddress);
		
		//RouteHelper rHelper = new RouteHelper();
		long runId = RouteHelper.addRouteToDb(getApplicationContext(), run);
		
		for(RoutePoints point: arrRoutePoints){
			point.setRunId((int)runId);
			PointHelper.addPointToRouteToDb(getApplicationContext(), point);
		}
		
        btnStart.setImageResource(R.drawable.go_sign);
        blnStarted = false;
        //btnStop.setVisibility(View.INVISIBLE);
	}
	
	@Override
    public void onMyLocationChange(Location location) {
		if(arrRoutePoints == null) {
			arrRoutePoints = new ArrayList<RoutePoints>();
		}
		
		if(arrLatLng == null) {
			arrLatLng = new ArrayList<LatLng>();
		}
		
		RoutePoints routePoint = new RoutePoints();
		routePoint.setLatitude(location.getLatitude());
		routePoint.setLongitude(location.getLongitude());
		routePoint.setAltitude(location.getAltitude());
		routePoint.setPointTime(location.getTime());
		arrRoutePoints.add(routePoint);
		
        // Getting latitude of the current location
        double latitude = location.getLatitude();
 
        // Getting longitude of the current location
        double longitude = location.getLongitude();
 
        // Creating a LatLng object for the current location
        LatLng latLng = new LatLng(latitude, longitude);
        arrLatLng.add(latLng);
        // Showing the current location in Google Map
        googleMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
 
        // Zoom in the Google Map
        googleMap.animateCamera(CameraUpdateFactory.zoomTo(15));
        
        drawPolyline();
    }
	
	public void drawPolyline() {
		//if less than 2 points do nothing. if exactly 2 points draw the initial polyline. if more than 2 points update the polyline 
        if(arrLatLng.size() == 2) {
        	PolylineOptions polyOptions = new PolylineOptions()
        	.color(Color.argb(255, 0, 0, 255))
    		.addAll(arrLatLng);

    		polyline = googleMap.addPolyline(polyOptions);
        } else if (arrLatLng.size() > 2){
    		polyline.setPoints(arrLatLng);
        }
	}

	@Override
	public void onClick(View v) {
		if(!blnStarted){
			startRun();
		}
		else if(blnStarted) {
			try{
				stopRun();
			} catch(Exception e){
				
			}
		}
	}
}