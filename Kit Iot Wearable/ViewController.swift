import UIKit
import CoreBluetooth
import CoreLocation
import MapKit


class ViewController: UIViewController,CLLocationManagerDelegate {

    // IB Outlets
    @IBOutlet weak var accelerometrX: UILabel!
    //var accxParam: String
    @IBOutlet weak var accelerometrY: UILabel!
    //var accyParam: String
    @IBOutlet weak var accelerometrZ: UILabel!
    //var acczParam: String
    @IBOutlet weak var impacto1     : UILabel!
    @IBOutlet weak var impacto2     : UILabel!
    @IBOutlet weak var impacto3     : UILabel!
    @IBOutlet weak var latitude     : UILabel?
    @IBOutlet weak var controleFibra     : UILabel!
    //var latitudeParam: String
    @IBOutlet weak var longitude    : UILabel?
    //var longitudeParam: String
    @IBOutlet weak var velocidade    : UILabel!
    @IBOutlet weak var luminosityValue: UILabel!
    @IBOutlet weak var temperatureValue: UILabel!
    @IBOutlet weak var temperatureValueNotFormat: UILabel!
    //var temperaturaParam: String
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!

    @IBOutlet weak var teste: UILabel!
    let blueColor = UIColor(red: 51/255, green: 73/255, blue: 96/255, alpha: 1.0)

    let redColor = UIColor(red: 255/255, green: 1/255, blue: 1/255, alpha: 1.0)
    
    var timer: NSTimer?
    
    var manager = CLLocationManager()

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self;
        manager.distanceFilter = kCLDistanceFilterNone; //whenever we move
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        manager.requestWhenInUseAuthorization()
    
        // Notification center observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"),
            name: WearableServiceStatusNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("characteristicNewValue:"),
            name: WearableCharacteristicNewValue, object: nil)
        
        //Wearable instance
        wearable
        
    }
    
    // MARK: - On characteristic new value update interface
    func characteristicNewValue(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, NSString>
        let value = userInfo["value"]!
        let val = value.substringFromIndex(3).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let sensor = value.substringWithRange(NSMakeRange(0, 3))
        
       updateMap(self);
        
        dispatch_async(dispatch_get_main_queue()) {
            switch sensor {
                case "#TE":
                    self.temperatureValue.text = "\(val)º"
                    break
            
                case "#LI":
                    self.luminosityValue.text = val
                    break
            
                case "#AX":
                    self.accelerometrX.text = val
                    break
            
                case "#AY":
                    self.accelerometrY.text = val
                    break
            
                case "#AZ":
                    self.accelerometrZ.text = val
                    break
                case "#I1":
                    self.impacto1.text = val
                    break
                case "#I2":
                    self.impacto2.text = val
                    break
                case "#I3":
                    self.impacto3.text = val
                    break
                case "#B1":
                    self.controleFibra.text = val
                    break
                default:
                    break
            }
        }
        
        
        // create the request & response
        var request = NSMutableURLRequest(URL: NSURL(string: "http://ytalomartins.cloudant.com/pactopelavida")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
        var response: NSURLResponse?
        var error: NSError?
        
        
        // Geração dos dados para o SPARK
        let batimentoCardiaco = arc4random_uniform(100)
        
        let impacto1 = arc4random_uniform(50)
        let impacto2 = arc4random_uniform(300)
        let impacto3 = arc4random_uniform(200)
        let impacto4 = arc4random_uniform(300)
        let impacto5 = arc4random_uniform(400)
        
        let accx = arc4random_uniform(250)
        let accy = arc4random_uniform(300)
        let accz = arc4random_uniform(150)
        
        let gx = arc4random_uniform(250)
        let gz = arc4random_uniform(300)
        let gy = arc4random_uniform(150)
        
        let temperaturaRandom = arc4random_uniform(30) + 35
        
        let date = NSDate()
        var formatter = NSDateFormatter();
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss";
        let defaultTimeZoneStr = formatter.stringFromDate(date);
        
    
        // create some JSON data and configure the request
        let jsonString : String = "{\"presidio\":\"Anibal\",\"detento\":\"João Figueiroa\", \"batimentoCardiaco\": \"\(batimentoCardiaco)\", \"dataHora\":\"\(defaultTimeZoneStr)\", \"temperatura\":\"\(temperaturaRandom)\",\"accx\":\"\(accx)\", \"accy\":\"\(accy)\", \"accz\":\" \(accz)\", \"gx\":\" \(gx)\", \"gy\":\" \(gy)\",\"gz\":\" \(gz)\",\"latitude\":\"\(self.latitude!.text!)\",\"longitude\":\"\(self.longitude!.text!)\",\"impacto1\":\"\(impacto1)\", \"impacto2\":\"\(impacto2)\", \"impacto3\":\"\(impacto3)\",\"impacto4\":\"\(impacto4)\", \"impacto5\":\"\(impacto5)\",\"velocidade\":\"\(self.velocidade.text!)\"}"
        
        println(jsonString)
        request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send the request
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        // look at the response
        if let httpResponse = response as? NSHTTPURLResponse {
            println("HTTP response: \(httpResponse.statusCode)")
        } else {
            println("No HTTP response")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        
        self.latitude!.text = NSString(format: "%.2f", locValue.latitude) as String?
        self.longitude!.text = NSString(format: "%.2f", locValue.longitude) as String?

        let ms = manager.location.speed

        self.velocidade.text = NSString(format: "%.2f", ms * 3.6) as String?
        
        //println("locations = \(locValue.latitude) \(locValue.longitude)")
        
        
        let latitude:CLLocationDegrees = locValue.latitude
        let longitude: CLLocationDegrees = locValue.longitude
        
        //change for Zoom Level
        let latDelta: CLLocationDegrees = 0.5
        let longDelta: CLLocationDegrees = 0.5
        
        //update the map
        var theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
        //self.theMap.setRegion(theRegion, animated: true)
        
        //stop updating location for manual update
        self.manager.stopUpdatingLocation()
        
    }
    
    func updateMap(sender: AnyObject) {
        
        if (CLLocationManager.locationServicesEnabled())
        {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
        }
    }
    
    // MARK: - On connection change
    func connectionChanged(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let isConnected: Bool = userInfo["isConnected"] {
                
                if isConnected {
                    self.wearableConnected()
                    
                } else {
                    self.wearableDisconnected()
                }
            }
        });
    }
    
    
    // MARK: - On wearable disconnection
    func wearableDisconnected() {
        // Change the title
        self.navigationController!.navigationBar.topItem?.title = "Detento desconectado... (Buscando)"
        
        self.navigationController!.navigationBar.barTintColor = self.redColor
        
        // Change naviagation color
        self.navigationController!.navigationBar.barTintColor = UIColor.grayColor()
        // Show loader
        self.loader.hidden = false
        // Show content view
        self.contentView.hidden = true
        // Cancel timer
        self.timer!.invalidate()
    }

    
    // MARK: - On wearable connection
    func wearableConnected() {
        //Change the title
        self.navigationController!.navigationBar.topItem?.title = "Detento conectado"
        //Change naviagation color
        self.navigationController!.navigationBar.barTintColor = self.blueColor
        // Hide loader
        self.loader.hidden = true
        // Show content view
        self.contentView.hidden = false
        
        // Get the sensor values
        self.getSensorValues()
        
        // Start timer
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("getSensorValues"), userInfo: nil, repeats: true)
        
    }
    
    
    // MARK: - Deinit and memory warning
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: WearableServiceStatusNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: WearableCharacteristicNewValue, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Slider change
    @IBAction func sliderChange(slider: UISlider) {
        if let wearableService = wearable.wearableService {
            if (slider.isEqual(redSlider)) {
                wearableService.sendCommand(String(format: "#LR0%.0f\n\r", slider.value))
            }
            
            if (slider.isEqual(greenSlider)) {
                wearableService.sendCommand(String(format: "#LG0%.0f\n\r", slider.value))
            }
            
            if (slider.isEqual(blueSlider)) {
                wearableService.sendCommand(String(format: "#LB0%.0f\n\r", slider.value))
            }
        }
    }
    
    
    // MARK: - Button click
    @IBAction func ledOFF(sender: AnyObject) {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand("#LL0000\n\r")
            
            redSlider.setValue(0, animated: true)
            greenSlider.setValue(0, animated: true)
            blueSlider.setValue(0, animated: true)
        }
    }
    
    
    // MARK: - Get {light,temperature,accelerometer} value
    func getSensorValues() {
        if let wearableService = wearable.wearableService {
            wearableService.sendCommand("#TE0000\n\r")
             wearableService.sendCommand("#LI0000\n\r")
            wearableService.sendCommand("#AC0003\n\r")
        }
    }
    
    
    // MARK: - Melody buttons click
    @IBAction func playMelody(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            case 0:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM1234\n\r")
                }
            
            case 1:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM6789\n\r")
                }
            
            case 2:
                if let wearableService = wearable.wearableService {
                    wearableService.sendCommand("#PM4567\n\r")
                }

            default:
                break;
        }
    }
}

