import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Weather;

class BetterWeatherView extends WatchUi.View {

    var screen_w;
    var screen_h;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        screen_w = dc.getWidth();
        screen_h = dc.getHeight();
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    private function addWeatherOrError() as Void {
        System.println("Updating weather text");
        var weatherLabel = View.findDrawableById("current_temperature") as Text;
        var weather = Application.Storage.getValue(BETTER_WEATHER_DATA) as WeatherData;
        if (weather == null) {
            weatherLabel.setText(Application.Storage.getValue(BETTER_WEATHER_ERROR));
        } else {
            var currentTemp = weather["currentTemperature"];
            weatherLabel.setText(currentTemp.format("%i"));
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        addWeatherOrError();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        System.println("Updating view");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        addWeatherOrError();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
