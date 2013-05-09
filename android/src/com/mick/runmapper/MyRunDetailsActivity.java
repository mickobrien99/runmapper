package com.mick.runmapper;

import java.util.ArrayList;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import com.mick.helpers.RoutesBaseAdapter;
import com.mick.helpers.PointHelper;
import com.mick.helpers.RouteHelper;
import com.mick.model.RoutePoints;
import com.mick.model.Runs;
import com.mick.runmapper.MyRunsActivity.LoadRunList;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.Dialog;
import android.app.FragmentManager;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.support.v4.app.FragmentActivity;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class MyRunDetailsActivity extends FragmentActivity {
	private ProgressDialog pDialog;
	private Runs run = new Runs(); 
	ArrayList<RoutePoints> myRoutePointsList;
	private TextView tvStartDate;
	private TextView tvFrom;
	private TextView tvTo;
	private TextView tvDistance;
	private TextView tvDuration;
	GoogleMap googleMap;
	ArrayList<LatLng> arrLatLng;
	Polyline polyline;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.run_details);
		
		run = (Runs) getIntent().getSerializableExtra("mRouteId");
		
		tvFrom = (TextView)findViewById(R.id.tv_my_run_route_from_value);
		tvTo = (TextView)findViewById(R.id.tv_my_run_route_to_value);
		tvStartDate = (TextView)findViewById(R.id.tv_my_run_route_start_date_value);
		tvDistance = (TextView)findViewById(R.id.tv_my_run_route_distance_value);
		tvDuration = (TextView)findViewById(R.id.tv_my_run_route_duration_value);
		tvFrom.setText(run.getStartAddress());
		tvTo.setText(run.getEndAddress());
		tvStartDate.setText(run.getStartTimestamp());
		tvDistance.setText(String.valueOf(run.getDistance()));
		tvDuration.setText(String.valueOf(run.getDuration()));
		
		// Getting Google Play availability status
        int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getBaseContext());
 
        // Showing status
        if(status!=ConnectionResult.SUCCESS) { // Google Play Services are not available
            int requestCode = 10;
            Dialog dialog = GooglePlayServicesUtil.getErrorDialog(status, this, requestCode);
            dialog.show();
        } else {    // Google Play Services are available
            // Getting reference to the SupportMapFragment of activity_main.xml
            SupportMapFragment fm = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
 
            // Getting GoogleMap object from the fragment
            googleMap = fm.getMap();
            
            new LoadRoutePointsList().execute();
        }
	}
	
	/**
	 * Background Async Task to Load all points from db
	 * */
	class LoadRoutePointsList extends AsyncTask<String, String, String> {
		/**
		 * Before starting background thread Show Progress Dialog
		 * */
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			pDialog = new ProgressDialog(MyRunDetailsActivity.this);
			pDialog.setMessage("Loading Route Info ...");
			pDialog.setIndeterminate(false);
			pDialog.setCancelable(false);
			pDialog.show();
		}

		protected String doInBackground(String... args) {
			myRoutePointsList = PointHelper.getPoints(getApplicationContext(), String.valueOf(run.getId()));
			arrLatLng = new ArrayList<LatLng>();
			
			for(int i = 0; i < myRoutePointsList.size(); i++) {
				RoutePoints point = myRoutePointsList.get(i);
				arrLatLng.add(new LatLng(point.getLatitude(), point.getLongitude()));
			}
			
			return null;
		}

		/**
		 * After completing background task Dismiss the progress dialog
		 * **/
		protected void onPostExecute(String file_url) {
			// dismiss the dialog after getting all products
			pDialog.dismiss();
			// updating UI from Background Thread
			runOnUiThread(new Runnable() {
				public void run() {
			        drawPolyline();
					//need plot points in date order to be plotted..could order by id..so that will put them in order...  	
				}
			});
		}
	}
	
	public void drawPolyline() {
		//if more than 1 point draw the polyline and zoom in on the start point
	    if(arrLatLng.size() > 1) {
	    	PolylineOptions polyOptions = new PolylineOptions()
	    	.color(Color.argb(255, 0, 0, 255))
			.addAll(arrLatLng);
	
			polyline = googleMap.addPolyline(polyOptions);
		    
		    LatLng latLng = new LatLng(arrLatLng.get(0).latitude, arrLatLng.get(0).longitude);
	        // Showing the current location in Google Map
	        googleMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));
	 
	        // Zoom in the Google Map
	        googleMap.animateCamera(CameraUpdateFactory.zoomTo(15));
	    }
	}
}