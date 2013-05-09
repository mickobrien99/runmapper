package com.mick.helpers;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import com.mick.model.Runs;
import com.mick.runmapper.R;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class RoutesBaseAdapter extends BaseAdapter {
	private static ArrayList<Runs> myRunsList;
	
	private LayoutInflater mInflater;

	public void deleteListItem(int index) {
		myRunsList.remove(index);
		notifyDataSetChanged();
	}
	
	public RoutesBaseAdapter(Context context, ArrayList<Runs> results) {
		myRunsList = results;
		mInflater = LayoutInflater.from(context);
	}

	public int getCount() {
		return myRunsList.size();
	}
	
	public Object getItem(int position) {
		return myRunsList.get(position);
	}
	
	public long getItemId(int position) {
		return position;
	}
	
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder;
		if (convertView == null) {
			convertView = mInflater.inflate(R.layout.myruns_list_item, null);
			holder = new ViewHolder();
			holder.txtRouteName = (TextView) convertView.findViewById(R.id.routename);
			holder.txtRouteSummary = (TextView) convertView.findViewById(R.id.routesummary);
			
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}

		String startAddrFirstLine = "unknown";
		
		if(myRunsList.get(position).getStartAddress() != null)
		{
			String[] startAddressLines = myRunsList.get(position).getStartAddress().split(",");
			
			if(startAddressLines != null) {
				startAddrFirstLine = startAddressLines[0];
			}
		}
		
		String endAddrFirstLine = "unknown";

		if(myRunsList.get(position).getEndAddress() != null)
		{
			String[] endAddressLines = myRunsList.get(position).getEndAddress().split(",");
			
			if(endAddressLines != null) {
				endAddrFirstLine = endAddressLines[0];
			}
		}
		
		String strRouteName = startAddrFirstLine + " to " + endAddrFirstLine;
		String strRouteSummary = String.valueOf(myRunsList.get(position).getStartTimestamp())  + ", " + myRunsList.get(position).getDistance() + "km, " + myRunsList.get(position).getDuration();
		
		holder.txtRouteName.setText(strRouteName);
		holder.txtRouteSummary.setText(strRouteSummary);
	
		return convertView;
	}

	static class ViewHolder {
		TextView txtRouteName;
		TextView txtRouteSummary;
	
	}
}