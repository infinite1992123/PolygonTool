//
//  ViewController.m
//  PolygonTool
//
//  Created by 赵剑秋 on 17/11/29.
//  Copyright © 2017年 赵剑秋. All rights reserved.
//

#import "ViewController.h"
#import <math.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //温馨提示:  看控制台输出
    
    //1.0  多边形中心  Polygon Center
    NSMutableArray *arr=[NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 2)],[NSValue valueWithCGPoint:CGPointMake(1, 1)],[NSValue valueWithCGPoint:CGPointMake(1, -1)],[NSValue valueWithCGPoint:CGPointMake(0, -2)],nil];
    
    CGPoint centerOfPolygon=[self getCenterOfPolygonVertices:arr];
    NSLog(@"center中心点坐标是%@",NSStringFromCGPoint(centerOfPolygon));
    
    
    
    
    
    
    
    //2.0  多边形拆分后三角形的顶点组合的三角形顶点集合 polygon-triangulation-into-triangle-strips
    
    NSArray *topResultArr=[self process:arr];
    
    
    //输出print
    int toptriAngleCount=(int)topResultArr.count/3;
    for (int n=0; n<toptriAngleCount; n++) {
        NSValue * p1Value=topResultArr[n*3+0];
        CGPoint p1 =p1Value.CGPointValue;
        
        NSValue * p2Value=topResultArr[n*3+1];
        CGPoint p2 = p2Value.CGPointValue;
        
        NSValue * p3Value = topResultArr[n*3+2];
        CGPoint p3 = p3Value.CGPointValue;
        
        NSLog(@"三角形下标为TriangleIndex%d%@%@%@",n,NSStringFromCGPoint(p1),NSStringFromCGPoint(p2),NSStringFromCGPoint(p3));
    }
    
}

/*!
 *  获取多边形的中心点和面积 Get the center and area of the polygon
 *  param 多边形的各个顶点 the coordinates of the vertices of the polygon
 */

-(CGPoint)getCenterOfPolygonVertices:(NSArray *)arr{

    float area=0.0;
    for (int i=0; i<arr.count; i++) {
        
        NSValue * pValue=arr[i];
        CGPoint point=pValue.CGPointValue;
        
        CGPoint nextPoint;
        if (i==arr.count-1) {
            NSValue *pointValue=arr[0];
            nextPoint=pointValue.CGPointValue;
        }else{
            NSValue *pointValue=arr[i+1];
            nextPoint=pointValue.CGPointValue;
        }
        
        area += point.x * nextPoint.y - nextPoint.x * point.y;
        
    }
    area=area/2.0;
    
    
    NSLog(@"area面积是:%f",fabsf(area));
    
    float tempX=0.0;
    float tempY=0.0;
    
    for (int i=0; i<arr.count; i++) {
        
        NSValue * pValue=arr[i];
        CGPoint point=pValue.CGPointValue;
        
        CGPoint nextPoint;
        if (i==arr.count-1) {
            NSValue *pointValue=arr[0];
            nextPoint=pointValue.CGPointValue;
        }else{
            NSValue *pointValue=arr[i+1];
            nextPoint=pointValue.CGPointValue;
        }
        
        tempX += (point.x+nextPoint.x) *
        (point.x * nextPoint.y - nextPoint.x * point.y);
        tempY += (point.y+nextPoint.y) *
        (point.x * nextPoint.y - nextPoint.x * point.y);
        
        
        
    }
    
    float centerX=1/(6.0*area) *
    tempX;
    float centerY=1/(6.0*area) *
    tempY;
    
    CGPoint centerP=CGPointMake(centerX, centerY);
    
    
    
    return centerP;
}



-(float)getArea:(NSMutableArray *)pointArr{
    
    float area=0.0;
    int n= (int)pointArr.count;
    for (int p=n-1,q=0; q<n; p=q++) {
        NSValue *pValue= pointArr[p];
        CGPoint p=pValue.CGPointValue;
        NSValue *qValue= pointArr[q];
        CGPoint q=qValue.CGPointValue;
        area+=p.x*q.y-q.x*p.y;
    }
    return area*0.5;
}
//决定是否点Px / Py为内部由三角形定义
-(bool)insideTriangle:(float)Ax :(float)Ay :(float)Bx :(float)By :(float)Cx :(float)Cy :(float)Px :(float)Py{
    
    BOOL isInside=NO;
    
    float ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
    
    float cCROSSap, bCROSScp, aCROSSbp;
    
    ax = Cx - Bx;  ay = Cy - By;
    bx = Ax - Cx;  by = Ay - Cy;
    cx = Bx - Ax;  cy = By - Ay;
    apx= Px - Ax;  apy= Py - Ay;
    bpx= Px - Bx;  bpy= Py - By;
    cpx= Px - Cx;  cpy= Py - Cy;
    
    aCROSSbp = ax*bpy - ay*bpx;
    cCROSSap = cx*apy - cy*apx;
    bCROSScp = bx*cpy - by*cpx;
    
    isInside=((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
    
    return isInside;
}
-(BOOL)snip:(NSMutableArray *)pointArr :(int)u :(int)v :(int)w :(int)n :(int[])V{
    
    int p;
    float Ax, Ay, Bx, By, Cx, Cy, Px, Py;
    
    
    
    
    NSValue *uvalue=pointArr[V[u]];
    CGPoint upoint=uvalue.CGPointValue;
    
    
    NSValue *vvalue=pointArr[V[v]];
    CGPoint vpoint=vvalue.CGPointValue;
    
    
    NSValue *wvalue=pointArr[V[w]];
    CGPoint wpoint=wvalue.CGPointValue;
    
    Ax = upoint.x;
    Ay = upoint.y;
    
    Bx = vpoint.x;
    By = vpoint.y;
    
    Cx = wpoint.x;
    Cy = wpoint.y;
    
    if ( 0.0000000001f > (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) ) return NO;
    
    for (p=0;p<n;p++)
    {
        if( (p == u) || (p == v) || (p == w) ) continue;
        
        NSValue *pvalue=pointArr[V[p]];
        CGPoint ppoint=pvalue.CGPointValue;
        Px = ppoint.x;
        Py = ppoint.y;
        BOOL isInside=[self insideTriangle:Ax :Ay :Bx :By :Cx :Cy :Px :Py];
        if (isInside) return NO;
    }
    
    return YES;
    
}
-(NSMutableArray *)process:(NSMutableArray *)pointArr{
    
    NSMutableArray *resultArr=[NSMutableArray array];
    NSMutableArray *nullArr=[NSMutableArray array];
    int n=(int)pointArr.count;
    if (n<3) {
        NSLog(@"三角形小于3个点");
        return nullArr;
    }
    
    //    NSMutableArray *V=[NSMutableArray array];
    int V[n];
    float area=[self getArea:pointArr];
    if (area>0.0) {
        for (int i=0; i<n; i++) {
            V[i]=i;
        }
    }else{
        
        for (int i=0; i<n; i++) {
            V[i]=n-1-i;
        }
    }
    
    int nv=n;
    int count =2*nv;
    
    for(int m=0, v=nv-1; nv>2; )
    {
        /* 如果我们循环，它可能是一个非简单的多边形 */
        if (0 >= (count--))
        {
            //** Triangulate：错误 - 可能的坏多边形!
            
            NSLog(@"错误 - 可能的坏多边形");
            return nullArr;
        }
        
        /* 当前多边形中的三个连续顶点，<u，v，w> */
        int u = v  ; if (nv <= u) u = 0;     /* previous */
        v = u+1; if (nv <= v) v = 0;     /* new v    */
        int w = v+1; if (nv <= w) w = 0;
        
        BOOL snip=[self snip:pointArr :u :v :w :nv :V];
        if ( snip )
        {
            int a,b,c,s,t;
            
            /* true names of the vertices顶点的真实名称 */
            
            a = V[u]; b = V[v]; c = V[w];
            
            /* output Triangle  输出三角形 */
            [resultArr addObject:pointArr[a]];
            [resultArr addObject:pointArr[b]];
            [resultArr addObject:pointArr[c]];
            
            m++;
            
            /* remove v from remaining polygon 从剩余的多边形中删除v   */
            for(s=v,t=v+1;t<nv;s++,t++) V[s] = V[t]; nv--;
            
            /* resest error detection counter resest错误检测计数器 */
            count = 2*nv;
        }
    }
    
    
    return resultArr;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
