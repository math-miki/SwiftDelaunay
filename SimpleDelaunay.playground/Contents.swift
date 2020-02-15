import Foundation
import simd
import UIKit
import CoreGraphics

// -------------------- CONST -------------------- //

let N = 10

// -------------------- MAIN -------------------- //

func main() {
    let image = Image(named: "miki.png")
    image.show()
    
    let randomPoints: [Point] = Array.init(repeating: generateRandomPoint(size: image.size), count: N).map{ $0() } + [Point(0, 0), Point(0, Float(image.size.height)), Point(Float(image.size.width), Float(image.size.height)), Point(Float(image.size.width), 0)]
//    let triangulation = generateTriangultion(points: randomPoints, size: image.size)
//    let triangles = triangulation()
    let triangles = triangultion(points: randomPoints, size: image.size)
    print(triangles.count)
    image.draw(triangles: triangles)
}

// -------------------- CORE -------------------- //

//func generateTriangultion(points: [Point], size: CGSize) -> Triangulation {
func triangultion(points: [Point], size: CGSize) -> [Triangle] {

    
    func redundanciesMap(triangleMap: inout Dictionary<Triangle, Bool>, newTriangle: Triangle) {
        if triangleMap.keys.contains(newTriangle) {
            triangleMap[newTriangle] = false
        } else {
            triangleMap[newTriangle] = true
        }
    }
    
    var triangles: [Triangle] = [Triangle]()
    let baseTriangle = getBaseTriangle(width: Float(size.width+100), height: Float(size.height+100))
    triangles.append(baseTriangle)
    
    for point in points {
        var tmpTriangleSet: Dictionary<Triangle, Bool> = Dictionary<Triangle, Bool>()
        
        for triangle in triangles {
            let circumscrivedCircle = getCircumscrivedCircle(of: triangle)
            
            if dist(circumscrivedCircle.c - point) < circumscrivedCircle.r {
                redundanciesMap(triangleMap: &tmpTriangleSet, newTriangle: Triangle(point, triangle.p1, triangle.p2))
                redundanciesMap(triangleMap: &tmpTriangleSet, newTriangle: Triangle(point, triangle.p2, triangle.p3))
                redundanciesMap(triangleMap: &tmpTriangleSet, newTriangle: Triangle(point, triangle.p3, triangle.p1))
            } else {
                redundanciesMap(triangleMap: &tmpTriangleSet, newTriangle: triangle)
            }
        }
    
        triangles.removeAll()
        for (triangle, isUnique) in tmpTriangleSet {
            if isUnique {
                triangles.append(triangle)
            }
        }
//        triangles = tmpTriangleSet.filter({ $1 }).map{ t, _ in t }
        
    }
    for (i, triangle) in triangles.enumerated().reversed() {
        if baseTriangle.hasCommonPoints(compareWith: triangle) {
            triangles.remove(at: i)
        }
    }
    return triangles
//    return triangles.filter{ !baseTriangle.hasCommonPoints(compareWith: $0) }
}

// -------------------- FUNCTIONS -------------------- //

func generateRandomPoint(size: CGSize) -> () -> Point {
    return  { () -> Point in
        Point(Float.random(in: 1 ..< Float(size.width)), Float.random(in: 1 ..< Float(size.height)))
    }
}

func dist(_ P: Point) -> Float {
    return sqrtf(simd_dot(P, P))
}

func getCircumscrivedCircle(of t: Triangle) -> Circle {
    let x1 = t.p1.x
    let y1 = t.p1.y
    let x2 = t.p2.x
    let y2 = t.p2.y
    let x3 = t.p3.x
    let y3 = t.p3.y

    let x12 = x1-x2
    let x13 = x1-x3
    let y12 = y1-y2
    let y13 = y1-y3
    let z21 = x2*x2 + y2*y2 - x1*x1 - y1*y1
    let z31 = x3*x3 + y3*y3 - x1*x1 - y1*y1
    let l = (y12*z31 - y13*z21) / (x13*y12 - x12*y13)
    let m = (z21 - x12*l)/y12
    let n = -1*(x1*x1 + y1*y1 + x1*l + y1*m)
    let cx = -1*l/2.0
    let cy = -1*m/2.0
    let r = sqrtf((l*l + m*m)/4.0 - n)

    return Circle(center: Point(cx, cy), radius: r)
}

func getBaseTriangle(width w: Float, height h: Float) -> Triangle {
    let r = sqrtf(w*w/4.0 + h*h/4.0)
    let l = 2*r*sqrtf(3)
    return Triangle(Point(w/2.0, h/2.0 + r - sqrtf(3)*l/2.0), Point((w-l)/2.0,h/2.0+r), Point((w+l)/2.0,h/2.0+r))
}

// -------------------- STRUCTURES -------------------- //

class Image {
    var cgImage: CGImage!
    var uiImage: UIImage!
    var pixels: UnsafePointer<UInt8>!
    
    private var _size: CGSize! = nil
    var size: CGSize {
        get {
            if _size == nil {
                _size = CGSize(width: cgImage.width, height: cgImage.height)
            }
            return _size
        }
    }
    
    init(named name: String) {
        guard let _uiImage = UIImage(named: name), let _cgImage = _uiImage.cgImage else { fatalError("missing image") }
        uiImage = _uiImage
        cgImage = _cgImage
        
        guard let provider = cgImage.dataProvider else { fatalError("cannot initialize provider") }
        guard let providerData = provider.data else { fatalError("cannot generate image data") }
        guard let data = CFDataGetBytePtr(providerData) else { fatalError("") }
        self.pixels = data
    }
    
    func show() {
        UIImageView(image: uiImage)
    }
    
    func draw(triangles: [Triangle]) {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            for triangle in triangles {
                ctx.cgContext.addLines(between: triangle.cgPoints)
                ctx.cgContext.drawPath(using: .stroke)
            }
        }
        UIImageView(image: image)
    }
}

protocol Figure {
    func draw()
}

typealias Point = SIMD2<Float>

struct Circle: Figure {
    var c: Point!
    var r: Float!
    init(center _c: Point, radius _r: Float) {
        c = _c
        r = _r
    }
    
    func draw() {
        print("Draw Circle at \(c.x), \(c.y), radius is \(r)")
    }
}

struct Triangle: Figure, Hashable {
    var p1: Point!
    var p2: Point!
    var p3: Point!
    
    var cgPoints: [CGPoint] {
        return [ CGPoint(x: CGFloat(p1.x), y: CGFloat(p1.y)), CGPoint(x: CGFloat(p2.x), y: CGFloat(p2.y)), CGPoint(x: CGFloat(p3.x), y: CGFloat(p3.y)) ]
    }
    
    init(_ _p1: Point, _ _p2: Point, _ _p3: Point) {
        p1 = _p1
        p2 = _p2
        p3 = _p3
    }
    
    func draw() {
        print("Draw Triangle at \(p1), \(p2), and \(p3)")
    }
    
    func hasCommonPoints (compareWith tri: Triangle) -> Bool {
        return self.p1 == tri.p1 || self.p1 == tri.p2 || self.p1 == tri.p3
            || self.p2 == tri.p1 || self.p2 == tri.p2 || self.p2 == tri.p3
            || self.p3 == tri.p1 || self.p3 == tri.p2 || self.p3 == tri.p3
    }

    static func == (lhs: Triangle, rhs: Triangle) -> Bool {
        return (lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2 && lhs.p3 == rhs.p3)
            || (lhs.p1 == rhs.p2 && lhs.p2 == rhs.p3 && lhs.p3 == rhs.p1)
            || (lhs.p1 == rhs.p3 && lhs.p2 == rhs.p1 && lhs.p3 == rhs.p2)
            || (lhs.p1 == rhs.p3 && lhs.p2 == rhs.p2 && lhs.p3 == rhs.p1)
            || (lhs.p1 == rhs.p2 && lhs.p2 == rhs.p1 && lhs.p3 == rhs.p3)
            || (lhs.p1 == rhs.p1 && lhs.p2 == rhs.p3 && lhs.p3 == rhs.p2)
    }
    
    func getGravity() -> Point {
        return Point(x: (p1.x+p2.x+p3.x)/3, y: (p1.y+p2.y+p3.y)/3)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(p1)
        hasher.combine(p2)
        hasher.combine(p3)
    }
}

typealias Triangulation = () -> [Triangle]


main()
