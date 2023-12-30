import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;

function handleWeatherData(weather) {
    System.println("Setting weather data in storage");
    Application.Storage.setValue(BETTER_WEATHER_DATA, weather);
    WatchUi.requestUpdate();
}