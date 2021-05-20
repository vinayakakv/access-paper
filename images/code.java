public class MainActivity extends Activity {
    private TextView status;
    private LocationManager locationManager;

    private final LocationListener locationListener = new LocationListener() {
        @Override
        public void onLocationChanged(final Location location) {
            status.setText(
                    String.format(
                            "Location: %f, %f",
                            location.getLongitude(),
                            location.getLatitude()
                    )
            );
        }
    };

    private final View.OnClickListener onClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            try {
                if (/*Permission Check*/) {
                    status.setText("Permission Not Granted");
                    return;
                }
                locationManager.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER,
                        1000,
                        (float) 0.01,
                        locationListener
                );
            } catch (Exception e) {
                status.setText(e.toString());
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Button button = findViewById(R.id.button);
        status = findViewById(R.id.status);
        locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
        button.setOnClickListener(onClickListener);
    }
}
