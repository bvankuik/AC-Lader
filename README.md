# AC-Lader

App to view AC chargers. List of chargers is retrieved by downloading KML from
http://ac-laders.nl/

# To do

The following features are outstanding:
* When tapping a placemarker description, show more details somehow, because
  GMSMapView cuts it off after a certain number of characters
* When tapping a placemarker, offer to set a route in Apple Maps or Google Maps
  as per: https://developers.google.com/maps/documentation/urls/guide
* Regularly poll and update KML from http://ac-laders.nl, then cache it
* Some chargers are not suitable for older Zoes. These should get mintgreen
  markers WITHOUT a dot. Figure out if the KML specifies this particular
  detail.
* Render HTML of placemark descriptions, instead of just stripping it
