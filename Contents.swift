import Foundation
import simd

// -------------------- MAIN -------------------- //

func main() {
    
}

// -------------------- CORE -------------------- //

func Triangultion() {
    
}

// -------------------- STRUCTURES -------------------- //

protocol Figure {
    func draw()
}

typealias Point = SIMD2<Float>

struct Circle: Figure {
    var c: Point!
    var r: Float!
    init(_c: Point, _r: Float) {
        c = _c
        r = _r
    }
    
    func draw() {
        print("Draw Circle at \(c.x), \(c.y), radius is \(r)")
    }
}

struct Triangle: Figure {
    var p1, p2, p3: Point!
    
    init(_p1: Point, _p2: Point, _p3: Point) {
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
    
}

