import Foundation
import simd

// -------------------- MAIN -------------------- //

func main() {
    
}

// -------------------- CORE -------------------- //

func Triangultion() {
    var triangleSet:Set<Triangle> = Set<Triangle>()
    
}

// -------------------- FUNCTIONS -------------------- //

func getCircumscrivedCircle(of t: Triangle) {
    let x1 = t.p1.x;
    let y1 = t.p1.y;
    let x2 = t.p2.x;
    let y2 = t.p2.y;
    let x3 = t.p3.x;
    let y3 = t.p3.y;

    let x12 = x1-x2;
    let x13 = x1-x3;
    let y12 = y1-y2;
    let y13 = y1-y3;
    let z21 = x2*x2 + y2*y2 - x1*x1 - y1*y1;
    let z31 = x3*x3 + y3*y3 - x1*x1 - y1*y1;
    let l = (y12*z31 - y13*z21) / (x13*y12 - x12*y13);
    let m = (z21 - x12*l)/y12;
    let n = -1*(x1*x1 + y1*y1 + x1*l + y1*m);
    let cx = -1*l/2.0;
    let cy = -1*m/2.0;
    let r = sqrt((l*l + m*m)/4.0 - n);

    return Circle(center: Point(cx, cy), radius: r);
}

func getBaseTriangle(width w: Int, height h: Int) {
    let r = sqrt(w*w/4.0 + h*h/4.0);
    let l = 2*r*sqrt(3);
    return Triangle(Point(w/2.0, h/2.0 + r - sqrt(3)*l/2.0), Point((w-l)/2.0,h/2.0+r), Point((w+l)/2.0,h/2.0+r));

}

// -------------------- STRUCTURES -------------------- //

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
    
    init(_ _p1: Point, _ _p2: Point, _ _p3: Point) {
        p1 = _p1
        p2 = _p2
        p3 = _p3
    }
    
    func draw() {
        print("Draw Triangle at \(p1), \(p2), and \(p3)")
    }
    
    func HasCommonPoints (compareWith tri: Triangle) -> Bool {
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
