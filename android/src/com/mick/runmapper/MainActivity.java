package com.mick.runmapper;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;


public class MainActivity extends TabActivity {
	// TabSpec Names
	private static final String TRACK_SPEC = "Record Route";
	private static final String MYRUNS_SPEC = "View My Routes";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main_activity);

		TabHost tabHost = getTabHost();

		// Track Tab
		TabSpec trackSpec = tabHost.newTabSpec(TRACK_SPEC);
		// Tab Icon
		trackSpec.setIndicator(TRACK_SPEC, getResources().getDrawable(R.drawable.icon_track));
		Intent trackIntent = new Intent(this, TrackActivity.class);
		// Tab Content
		trackSpec.setContent(trackIntent);

		// MyRuns Tab
		TabSpec myrunsSpec = tabHost.newTabSpec(MYRUNS_SPEC);
		myrunsSpec.setIndicator(MYRUNS_SPEC, getResources().getDrawable(R.drawable.icon_myruns));
		Intent myrunsIntent = new Intent(this, MyRunsActivity.class);
		myrunsSpec.setContent(myrunsIntent);
		myrunsIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

		// Adding all TabSpec to TabHost
		tabHost.addTab(trackSpec); // Adding Track tab
		tabHost.addTab(myrunsSpec); // Adding My Runs tab
	}
}