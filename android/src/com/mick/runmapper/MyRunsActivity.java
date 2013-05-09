package com.mick.runmapper;

import java.util.ArrayList;

import com.mick.helpers.RoutesBaseAdapter;
import com.mick.helpers.RouteHelper;
import com.mick.model.Runs;

import android.app.Activity;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextMenu;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AdapterView;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.ArrayAdapter;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

import android.widget.AdapterView.OnItemClickListener;

public class MyRunsActivity extends Activity {
	private ProgressDialog pDialog;
	private static ListView lv1 = null;
	ArrayList<Runs> myRunsList;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.myruns_list);

		myRunsList = new ArrayList<Runs>();
		lv1 = (ListView)findViewById(R.id.listruns);
		
		// Loading Runs in Background Thread
		new LoadRunList().execute();
	}

	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,ContextMenu.ContextMenuInfo menuInfo) {
		super.onCreateContextMenu(menu, v, menuInfo);
		getMenuInflater().inflate(R.menu.route_list_item_menu, menu);
		menu.setHeaderTitle("Select an Option");
	}
	
	@Override
	public boolean onContextItemSelected(MenuItem item) {
		AdapterContextMenuInfo info = (AdapterContextMenuInfo) item.getMenuInfo();
		
		Object o = lv1.getItemAtPosition(info.position);
		Runs fullObject = (Runs)o;
		
		switch(item.getItemId()) {
		case R.id.menu_view:
			Toast.makeText(MyRunsActivity.this,"View Operation is performed!",Toast.LENGTH_SHORT ).show();
			Intent intent = new Intent();
			intent.setClass(MyRunsActivity.this, MyRunDetailsActivity.class);
			intent.putExtra("mRouteId", fullObject);
			startActivity(intent);
			return true;
		case R.id.menu_delete:
			if(fullObject.getId() != 0) {
				if(RouteHelper.deleteRoute(getApplicationContext(), String.valueOf(fullObject.getId()))){
					Toast.makeText(MyRunsActivity.this,"Route has been deleted!",Toast.LENGTH_SHORT ).show();
					
					((RoutesBaseAdapter) lv1.getAdapter()).deleteListItem(info.position);
				} else {
					Toast.makeText(MyRunsActivity.this,"Could not delete that route!",Toast.LENGTH_SHORT ).show();
				} 
			} else {
				Toast.makeText(MyRunsActivity.this,"Cannot delete this dummy route!",Toast.LENGTH_SHORT ).show();
			}
			return true;
		}
		return super.onContextItemSelected(item);
	}


	/**
	 * Background Async Task to Load all routes from db
	 * */
	class LoadRunList extends AsyncTask<String, String, String> {
		/**
		 * Before starting background thread Show Progress Dialog
		 * */
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			pDialog = new ProgressDialog(MyRunsActivity.this);
			pDialog.setMessage("Loading Runs ...");
			pDialog.setIndeterminate(false);
			pDialog.setCancelable(false);
			pDialog.show();
		}

		protected String doInBackground(String... args) {
			myRunsList = RouteHelper.getRoutes(getApplicationContext());
			return null;
		}

		/**
		 * After completing background task Dismiss the progress dialog
		 * **/
		protected void onPostExecute(String file_url) {
			// dismiss the dialog after getting all routes
			pDialog.dismiss();
			// updating UI from Background Thread
			runOnUiThread(new Runnable() {
				public void run() {

					lv1.setAdapter(new RoutesBaseAdapter(getApplicationContext(), myRunsList));

					lv1.setOnItemClickListener(new OnItemClickListener()
					{
						@Override
						public void onItemClick(AdapterView<?> a, View v, int position, long id) {
							Object o = lv1.getItemAtPosition(position);
							Runs fullObject = (Runs)o;

							Intent intent = new Intent();
							intent.setClass(MyRunsActivity.this, MyRunDetailsActivity.class);
							intent.putExtra("mRouteId", fullObject);
							startActivity(intent);
						}
					});
					lv1.setOnCreateContextMenuListener(new View.OnCreateContextMenuListener() {
						
						@Override
						public void onCreateContextMenu(ContextMenu menu, View v,
								ContextMenuInfo menuInfo) {
							// TODO Auto-generated method stub
							
							getMenuInflater().inflate(R.menu.route_list_item_menu, menu);
						}
					});
				}
			});
		}
	}
}