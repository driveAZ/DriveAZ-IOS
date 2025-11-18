# DriveAZ iOS App

## What is DriveAZ?

DriveAZ is an iOS app designed to improve road safety by showing real-time safety messages on a map. The app helps drivers and vulnerable road users (like pedestrians and cyclists) become aware of nearby hazards, work zones, and other important events. It uses your phone’s sensors and location to both display and broadcast safety information.

---

## What You’ll See in the App

### Map Pins

On the map, you’ll see pins representing different types of safety messages:

- **Cars**: Shown when another vehicle is broadcasting its presence.
- **Pedestrians**: Shown when a person is broadcasting a safety message.
- **Cyclists**: Shown when a cyclist is broadcasting a safety message.
- **Traffic Jams**: Shown when there’s a “Back of Queue” (traffic jam) message.
- **Work Zones**: Shown when there’s a road work or construction zone ahead.

Each pin uses a unique icon so you can quickly tell what type of message it represents.

#### How Pins Work: 1-to-1 with MQTT Messages

Each pin on the map directly represents a message received from the MQTT server. There is a one-to-one mapping: every message the app receives from the server is shown as a pin. The server only sends you messages for hazards or users that are near your current location. Moving the map will not reveal additional pins, only your actual location determines which messages you see. Pins stay on the map for 10 seconds after the app receives the last message for that pin.

---

### Alert Banners

Sometimes, a message is important enough to show as a banner at the top of the screen. This happens when:

- You are moving (driving, biking, etc.), and
- You are approaching a safety message (like a pedestrian, cyclist, traffic jam, or work zone) and are within a certain distance.
- **Importantly, the alert will only show if you are headed in the direction of the alert.** The app checks your course and only displays the banner if the hazard is in front of you, not behind or far off to the side. The course is provided by GPS and is the direction the phone is moving, the orientation of the phone does not matter. The app checks in a 45 degree cone in front of you, 22.5 degrees on either side.

The banner will show the type of alert (e.g., “Pedestrian Ahead” or “Work Zone Ahead”) and will disappear after a few seconds. The banner then will not show for another 30 seconds, even if you still meet the criteria. 

#### How Close Do I Need to Be for an Alert Banner?

The distance at which you see an alert banner depends on your speed. The app uses a safety formula based on stopping distances. Here are some example values:

| Your Speed (mph) | Distance for Alert Banner (feet) |
|------------------|----------------------------------|
| 25               | ~300                            |
| 55               | ~700                             |
| 70               | ~950                         |

- At lower speeds, you’ll get alerts closer to the hazard.
- At higher speeds, you’ll get alerts farther away, giving you more time to react.
- For work zones, the alert may appear up to 1,600 feet (about 500 meters) away, regardless of speed.

---

## The Settings Page

The app includes a settings page where you can adjust how it works and access debug features. Here’s what you’ll find:

### Main Settings

- **VRU Mode**: When enabled, your phone will broadcast your presence as a pedestrian or cyclist to nearby vehicles and other users via the MQTT broker.
- **Send While Not Moving**: If enabled, the app will continue to send your safety messages even when you’re standing still (useful for testing or special scenarios).
- **Publish/Subscribe to Public/Vendor Topic**: By default we publish to the public topic and listen on all topics.

### Debug and Information

- **Seen Messages**: Shows a list of all the safety messages your app has recently received, including their type and unique ID.
- **Messages Sent/Received**: Displays how many messages your app has sent and received.
- **Is Connected**: Shows whether your app is currently connected to the safety message network.
- **MQTT Server**: Displays the address of the server your app is using to send/receive messages. The important bit is the three letter code after "imp-".
- **PSMs/TIMs unable to process**: Shows if there were any errors decoding messages from pedestrians/cyclists (PSM) or traffic/work zone messages (TIM).

---
## MQTT Server Locations

During registration, the app determines which MQTT server to use based on your location. The following are the main server locations (used as reference points):

- **Phoenix, AZ**: (33.4351, -112.0108)
- **Atlanta, GA**: (33.6323, -84.4348)
- **Detroit, MI**: (42.2129, -83.3521)
- **New York City, NY**: (40.6379, -73.7778)
- **Los Angeles, CA**: (33.9420, -118.4037)

The app will connect to the server closest to your current location. This ensures you only receive messages relevant to your area.

---

## Notes for Testers

- The app is designed for both real-world use and testing. Debug features are available in the settings for advanced users.
- If you encounter issues, check you are connected and the server is your closest one as a sanity check
- For best results, keep the app open and allow it to access your location at all times.

---

## Changes needed if new AWS instance is created

- The `certURL` in the `ETXRegistrationManager` will need to be changed to a domain of your choosing. It must match the domain specified in uofa-driveaz-msgrouter.
- The `generateKey` in the `ETXRegistrationManager` needs to be updated to the `GENERATE_API_KEY` secret from the new AWS instance