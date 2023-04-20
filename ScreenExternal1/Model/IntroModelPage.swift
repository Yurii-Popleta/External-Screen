//
//  IntroModelPage.swift
//  ScreenExternal1
//
//  Created by Admin on 01/04/2023.

import Foundation

struct Page: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var description: String
    var imageName: String
    var tag: Int
    
    static var samplePages: [Page] = [
        Page(name: "Please read this before using the app.", description: "First of all, you need to connect an external screen. This can be done in two ways, the first is to connect the screen using AirPlay, to do this you need to open the control center, select the icon shown above, and select the screen to which you want to connect. To read the second method, click next.", imageName: "introPage1", tag: 0),
        Page(name: "Please read this before using the app.", description: "The second way with the appropriate cable or adapter, you can connect your iPhone to a secondary display, like a computer monitor, TV, or projector. \nAfter you use one of the methods in the upper window, you will see information about the size of the connected screen on a green background.", imageName: "introPage2", tag: 1),
        Page(name: "Please read this before using the app.", description: "After you've connected your screen and added your own photos or videos, select the type of photo or video presentation.", imageName: "introPage3", tag: 2)]
}
