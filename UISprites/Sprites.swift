//
//  Sprite.swift
//  UISprite
//
//  Created by Jonathan French on 14/01/2020.
//  Copyright © 2019 Jaypeeff. All rights reserved.
//

import UIKit

//[.clear,.white,.red,.blue,.green,.yellow,.magenta,.cyan,.orange,.brown,.lightGray]
public let deadColors:[UIColor] = [.red,.orange,.yellow]

public protocol Animates {
    var frames:Int {get set}
   // var animateArray:[[UIColor]] {get set}
    mutating func animate()
}

open class UISprite {
    
    var height:Int = 0
    var width:Int = 0
    var colour:UIColor = UIColor.clear
    var animationSpeed:Double = 0.1
    var coloursArray:[UIColor] = []
    var animateArray:[[UIColor]] = [[]]
    public var viewArray:[UIView] = []
    public var spriteView:UIView?
    public var pixWidth:Int = 0
    public var pixHeight:Int = 0
    public var frames: Int = 0
    public var currentFrame = 0
    public var isDead:Bool = false
    public var isDying:Bool = false
    public var stopAnimating:Bool = false

    public init(pos:CGPoint,height:Int,width:Int,animateArray:[[UIColor]],frameWith:Int,frameHeight:Int,frames:Int,speed:Double = 0.1) {
        self.position = pos
        self.height = height
        self.width = width
        self.animateArray = animateArray
        self.frames = frames
        self.pixWidth = frameWith
        self.pixHeight = frameHeight
        self.animationSpeed = speed
        
        spriteView = UIView(frame: CGRect(origin: self.position, size: CGSize(width: width, height: height)))
        spriteView?.backgroundColor = colour
        viewArray = layoutSprite(pixWidth,pixHeight,animateArray[0],spriteView!)
    }
    
    public init(pos:CGPoint,height:Int,width:Int,coloursArray:[UIColor],frameWith:Int,frameHeight:Int) {
        self.position = pos
        self.height = height
        self.width = width
        self.coloursArray = coloursArray
        self.frames = 1
        self.pixWidth = frameWith
        self.pixHeight = frameHeight
        
        spriteView = UIView(frame: CGRect(origin: self.position, size: CGSize(width: width, height: height)))
        spriteView?.backgroundColor = colour
        viewArray = layoutSprite(pixWidth,pixHeight,coloursArray,spriteView!)
    }
    
    deinit {
        for v in spriteView!.subviews {
            v.removeFromSuperview()
        }
    }
    
    public var position:CGPoint = CGPoint(x: 0, y: 0) {
        didSet{
            if let v = spriteView {
                v.center = position
            }
        }
    }
    
    open func checkHit(pos:CGPoint) -> Bool {
        guard !isDead else {
            return false
        }
        if let spriteView = spriteView {
            if spriteView.frame.contains(pos){
                isDying = true
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    
                }
                return true
            }
        }
        return false
    }
    
    open func checkHit(pos:CGRect) -> Bool {
        guard !isDead else {
            return false
        }
        if let spriteView = spriteView {
            if spriteView.frame.intersects(pos) {
                isDying = true
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                return true
            }
        }
        return false
    }
    
    public func move(x:Int,y:Int) {
        var newPos = position
        newPos.x = newPos.x + CGFloat(x)
        newPos.y = newPos.y + CGFloat(y)
        position = newPos
    }
    
}

extension UISprite {
    public func startAnimating(){
        stopAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + animationSpeed) {
            self.animate()
        }
    }
}
extension UISprite {
    public func startAnimatingNow(){
        stopAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.animate()
        }
    }
}

extension UISprite {
    open func animate() {
        if stopAnimating {            
            return
        }
        if isDying && !isDead {
            //UISprites.animateDying(coloursArray: animateArray,frame: currentFrame,pixels: viewArray)
            self.animateMeDying()
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self.isDead = true
                self.spriteView?.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                self.spriteView?.alpha = 0
            }, completion: { (finished: Bool) in
                self.spriteView?.removeFromSuperview()
                self.isDying = false
            })
            startAnimating()
        } else if isDying {
            //UISprites.animateDying(coloursArray: animateArray,frame: currentFrame,pixels: viewArray)
            self.animateMeDying()
            currentFrame += 1
            if currentFrame == self.frames{
                currentFrame = 0
            }
            startAnimating()
        } else if !isDead && !isDying {
            self.animateMe()
            //UISprites.animate(coloursArray: animateArray,frame: currentFrame,pixels: viewArray)
            currentFrame += 1
            if currentFrame == self.frames {
                currentFrame = 0
            }
            startAnimating()
        }
    }
    
    
    private func animateMe() -> Void {
    let _ = animateArray[currentFrame].enumerated().map {(index, item) in viewArray[index].backgroundColor = item }
        
        //pixels.map { $0.backgroundColor = coloursArray}
        //let cols = animateArray[currentFrame]
//        for (index, item) in animateArray[currentFrame].enumerated() {
//            viewArray[index].backgroundColor = item
//        }
        
    }
    
    private func animateMeDying() -> Void {
        self.animationSpeed = 0.1
        let _ = animateArray[currentFrame].enumerated().map {(index, item) in viewArray[index].backgroundColor = item }

//        for (index, item) in animateArray[currentFrame].enumerated() {
//            viewArray[index].backgroundColor = item
//        }
        let _ = viewArray.filter{ $0.backgroundColor?.cgColor.alpha != 0 }.map {
            let i = Int.random(in: 0 ..< 3)
            $0.backgroundColor = deadColors[i]
         }
//        for p in viewArray {
//            if p.backgroundColor?.cgColor.alpha != 0 {
//                let i = Int.random(in: 0 ..< 3)
//                p.backgroundColor = deadColors[i]
//            }
//        }
    }
    
    public func reDraw(coloursArray:[UIColor]) {
        self.coloursArray = coloursArray
        let _ = coloursArray.enumerated().map {(index, item) in viewArray[index].backgroundColor = item }

//        for (index, item) in coloursArray.enumerated() {
//            viewArray[index].backgroundColor = item
//            //pixels[index].backgroundColor = colors[item]
//        }
    }
    
    public func rotateMe(){
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.spriteView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
                           self.spriteView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
        }, completion: nil)
    }
    
    public func rotateMeTo(angle:CGFloat,duration:Double) {
            UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
                self.spriteView!.transform = CGAffineTransform(rotationAngle: CGFloat(angle * .pi/180))
            }, completion: { (finished: Bool) in }
        )
    }
    
}



//public func animate(coloursArray:[[UIColor]],frame:Int,pixels:[UIView]) -> Void {
////    pixels.enumerated().map {(index, view) in view.backgroundColor = coloursArray[frame,index] }
//    //pixels.map { $0.backgroundColor = coloursArray}
//    //let cols = coloursArray[frame]
//    for (index, item) in coloursArray[frame].enumerated() {
//        pixels[index].backgroundColor = item
//    }
//
//}
//
//public func animateDying(coloursArray:[[UIColor]],frame:Int,pixels:[UIView]) -> Void {
//
//    for (index, item) in coloursArray[frame].enumerated() {
//        pixels[index].backgroundColor = item
//    }
//    for p in pixels {
//        if p.backgroundColor?.cgColor.alpha != 0 {
//            let i = Int.random(in: 0 ..< 3)
//            p.backgroundColor = deadColors[i]
//        }
//    }
//}

let layoutSprite = {(pixWidth:Int,pixHeight:Int,coloursArray:[UIColor],spriteView:UIView) -> [UIView] in
    var viewArray:[UIView] = []
    var constraintsArray:[NSLayoutConstraint] = []
    let wid = Int(spriteView.frame.width) / pixWidth
    let hig = Int(spriteView.frame.height) / pixHeight
    
    for w in 0...coloursArray.count-1 {
        let p = coloursArray[w]
        
        let v:UIView = UIView(frame: CGRect(x: (w % pixWidth) * hig , y: (w / pixHeight) * wid , width: wid, height: hig))
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        constraintsArray.append(heightConstraint(v,spriteView,pixHeight))
        constraintsArray.append(widthConstraint(v,spriteView,pixWidth))
        if w < pixWidth { //top row
            //print("Top row \(w)")
            constraintsArray.append(topConstraint(v,spriteView))
        }
        else if w >= (pixHeight - 1) * (pixWidth ) { //bottom row
            //print("Bottom row \(w)")
            constraintsArray.append(bottomConstraint(v,spriteView))
        } else {
            constraintsArray.append(topPixelConstraint(v,viewArray[w-pixWidth]))
        }
        
        if w % pixWidth == 0 { //left pos
            //print("Left row \(w)")
            constraintsArray.append(leftConstraint(v,spriteView))
        } else if w % pixWidth == pixWidth - 1 { //right pos
            //print("Right row \(w)")
            constraintsArray.append(rightConstraint(v,spriteView))
            constraintsArray.append(leftPixelConstraint(v,viewArray[w-1]))
        } else {
            constraintsArray.append(leftPixelConstraint(v,viewArray[w-1]))
        }
        
        v.backgroundColor = p
        viewArray.append(v)
        spriteView.addSubview(v)
        
    }
    NSLayoutConstraint.activate(constraintsArray)
    return viewArray
}


let heightConstraint = {(me:UIView,toView:UIView,height:Int) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: toView.frame.height / CGFloat(height))
}

let widthConstraint = {(me:UIView,toView:UIView,width:Int) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: toView.frame.width / CGFloat(width))
}

let topConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
}

let topPixelConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
}

let leftConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
}

let leftPixelConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
}

let rightConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
}

let bottomPixelConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
}

let bottomConstraint = {(me:UIView, toView:UIView) -> NSLayoutConstraint in
    return NSLayoutConstraint(item: me, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: toView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
}


