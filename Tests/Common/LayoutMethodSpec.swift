//  Copyright (c) 2017 Luc Dion
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Quick
import Nimble
import PinLayout

class LayoutMethodSpec: QuickSpec {
    override func spec() {
        var viewController: PViewController!
        var rootView: BasicView!
        var aView: BasicView!
        
        /*
          root
           |
            - aView
        */
        
        beforeEach {
            _pinlayoutSetUnitTest(scale: 2)
            Pin.lastWarningText = nil
            Pin.logMissingLayoutCalls = false
            
            viewController = PViewController()
            viewController.view = BasicView()
            
            rootView = BasicView()
            rootView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            viewController.view.addSubview(rootView)
            
            aView = BasicView()
            aView.frame = CGRect(x: 40, y: 100, width: 100, height: 60)
            rootView.addSubview(aView)
        }

        afterEach {
            _pinlayoutSetUnitTest(scale: nil)
            Pin.logMissingLayoutCalls = false
        }
        
        //
        // layout()
        //
        describe("layout()") {
            it("test layout() method") {
                let aViewFrame = aView.frame
                aView.pin.left().right()
                expect(aView.frame).to(equal(CGRect(x: 0.0, y: 100.0, width: 400.0, height: 60.0)))
                expect(Pin.lastWarningText).to(beNil())
                
                aView.frame = aViewFrame
                aView.pin.left().right().layout()
                expect(aView.frame).to(equal(CGRect(x: 0.0, y: 100.0, width: 400.0, height: 60.0)))
            }
            
            it("should warn if layout() is not called when Pin.logMissingLayoutCalls is set to true") {
                Pin.logMissingLayoutCalls = true
                
                aView.pin.left().right()
                expect(Pin.lastWarningText).to(contain(["PinLayout commands have been issued without calling the 'layout()' method"]))
            }
        }

        #if os(iOS) || os(tvOS)
        describe("autoSizeThatFits()") {
            it("should include edge offsets in the resulting size") {
                defer { Pin.layoutDirection(.auto) }

                let bView = BasicView()
                rootView.addSubview(bView)

                let aViewFrame = aView.frame
                let bViewFrame = bView.frame
                let availableSize = CGSize(width: 400, height: 400)

                func performLayout() {
                    aView.pin.size(50).start(16).top(16).bottom(16)
                    bView.pin.size(50).top(16).end(16).bottom(16)
                }

                func autoSizedResult() -> CGSize {
                    return rootView.autoSizeThatFits(availableSize, layoutClosure: performLayout)
                }

                Pin.layoutDirection(.ltr)
                let size = autoSizedResult()
                expect(size).to(equal(CGSize(width: 400, height: 82)))

                expect(aView.frame).to(equal(aViewFrame))
                expect(bView.frame).to(equal(bViewFrame))

                rootView.frame = CGRect(origin: .zero, size: size)
                performLayout()
                expect(aView.frame).to(equal(CGRect(x: 16, y: 16, width: 50, height: 50)))
                expect(bView.frame).to(equal(CGRect(x: 334, y: 16, width: 50, height: 50)))

                Pin.layoutDirection(.rtl)
                expect(autoSizedResult()).to(equal(size))

                performLayout()
                expect(aView.frame).to(equal(CGRect(x: 334, y: 16, width: 50, height: 50)))
                expect(bView.frame).to(equal(CGRect(x: 16, y: 16, width: 50, height: 50)))
            }

            it("should preserve negative leading edge offsets") {
                let size = rootView.autoSizeThatFits(CGSize(width: 400, height: 400)) {
                    aView.pin.left(-10).top(-20).size(50)
                }

                expect(size).to(equal(CGSize(width: 50, height: 50)))
            }
        }
        #endif
    }
}
