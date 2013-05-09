package com.mick.model;

public class RoutePoints {
	private int id;
	private double latitude;
	private double longitude;
	private double altitude;
	private long pointTime;
	private int runId;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public double getLatitude() {
		return latitude;
	}
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	public double getLongitude() {
		return longitude;
	}
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	public double getAltitude() {
		return altitude;
	}
	public void setAltitude(double altitude) {
		this.altitude = altitude;
	}
	public long getPointTime() {
		return pointTime;
	}
	public void setPointTime(long pointTime) {
		this.pointTime = pointTime;
	}
	public int getRunId() {
		return runId;
	}
	public void setRunId(int runId) {
		this.runId = runId;
	}
}
