import Toybox.Communications;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;

typedef WeatherData as interface {
    var currentTemperature as Number;
    var currentWindSpeed as Number;
    // Wind direction given in degrees
    var currentWindDirection as Number;
    // WMO codes: https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM
    var currentWeatherCode as Number;
    var isDay as Boolean;
};


class OpenMeteoWeather {
    function getWeather(callback as Method) as Void {
        // Get location first
        var positionInfo = Position.getInfo().position;
        if (positionInfo == null) {
            Application.Storage.setValue(BETTER_WEATHER_ERROR, LOCATION_NOT_AVAILABLE_ERROR);
            System.println("Failed to fetch position data");
            callback.invoke(null);
        }
        var positionInDegrees = positionInfo.toDegrees();
        var lat = positionInDegrees[0];
        var long = positionInDegrees[1];
        System.println("Fetched position data");

        var url = "https://api.open-meteo.com/v1/forecast";
        var params = {
            "latitude" => lat,
            "longitude" => long,
            "current" => "temperature_2m,is_day,weather_code,wind_speed_10m,wind_direction_10m"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :context => {
                "callback" => callback
            }
        };

        // Make request to OpenMeteo
        System.println("Making web request");
        Communications.makeWebRequest(url, params, options, method(:processResponse));
    }

    public function processResponse(
        responseCode as $.Toybox.Lang.Number, 
        data as Null or $.Toybox.Lang.Dictionary or $.Toybox.Lang.String, 
        context as $.Toybox.Lang.Object
    ) as Void {
        System.println("Processing response");
        // Convert weather data if necessary, and package result as a WeatherInfo before invoking callback
        if (responseCode != 200) {
            System.println("Request failed");
            Application.Storage.setValue(BETTER_WEATHER_ERROR, API_REQUEST_FAILED_ERROR);
            method(context["callback"]).invoke(null);
            return;
        }

        System.println("Converting weather data");
        var deviceSettings = System.DeviceSettings;
        // Convert to Farenheight if required
        var currentTemp;
        if (deviceSettings.temperatureUnits != System.UNIT_METRIC) {
            currentTemp = 32 + ((9/5) * data["current"]["temperature_2m"]);
            System.println(Lang.format("Converted $1$C to $2$F", [data["current"]["temperature_2m"], currentTemp]));
        } else {
            currentTemp = data["current"]["temperature_2m"];
        }

        // Convert to MpH if required
        var windSpeed;
        if (deviceSettings.distanceUnits != System.UNIT_METRIC) {
            windSpeed = data["current"]["wind_speed_10m"] * 0.621371;
            System.println(Lang.format("Converted $1$kph to $2$mph", [data["current"]["wind_speed_10m"], windSpeed]));
        } else {
            windSpeed = data["current"]["wind_speed_10m"];
        }

        // Build and return weather dat
        var weatherData = {
            "currentTemperature" => currentTemp,
            "currentWindSpeed" => windSpeed,
            "currentWindDirection" => data["current"]["wind_direction_10m"],
            "currentWeatherCode" => data["current"]["weather_code"],
            "isDay" => data["current"]["is_day"]
        };
        System.println("Invoking callback");
        method(context["callback"]).invoke(weatherData);
    }
}