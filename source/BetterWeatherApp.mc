import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class BetterWeatherApp extends Application.AppBase {
    var openMeteoWeather;

    function initialize() {
        AppBase.initialize();
        Application.Storage.setValue(BETTER_WEATHER_ERROR, WAITING_MESSAGE);
        openMeteoWeather = new OpenMeteoWeather();
        System.println("Initialized app");
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        openMeteoWeather.getWeather(:handleWeatherData);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new BetterWeatherView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as BetterWeatherApp {
    return Application.getApp() as BetterWeatherApp;
}