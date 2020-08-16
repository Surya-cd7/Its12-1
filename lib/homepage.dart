import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:its12/items/item_class.dart';
import 'package:its12/pages/cart.dart';
import 'package:its12/pages/categoryItemsPage.dart';
import 'package:its12/pages/profile.dart';
import 'package:its12/pages/search_page.dart';
import 'package:its12/services/category_services.dart';
import 'package:its12/services/item_services.dart';

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Firestore db = Firestore.instance;
  FirebaseDatabase _database = FirebaseDatabase.instance;
  String name;
  int itemlen;
  bool categoryisLoading;
  List<Map<String, dynamic>> categoryItems=[];
  List<Map<String, dynamic>> productItems=[];
  Category_services category_services = Category_services();
  Item_services item_services = Item_services();
  String email;
  String photourl;
  Future getUser()async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState((){
     name = user.displayName;
     email = user.email;
     photourl = user.photoUrl;
    });
  }

  @override
  void initState() {
    category_services.getCategories().then(
      (value){
        setState(() {
         categoryItems = value;
        });
      }
      );
    item_services.getItems()
    .then((value){
      setState(() {
        productItems = value;
      });
    });
    getUser();
    super.initState();
      }

  @override
  void dispose() { 
    productItems.clear();
    categoryItems.clear();
    super.dispose();
  }

  int photoIndex = 0;
  static List photos = [
    'assets/images/bouquets.png',
    'assets/images/cakes.png',
    'assets/images/gifts.png',
    'assets/images/teddys.png',
    'assets/images/watches.png',
    'assets/images/bouquets.png',
    'assets/images/cakes.png',
    'assets/images/gifts.png',
    'assets/images/teddys.png',
    'assets/images/watches.png',];

  List<String> tile = ['Home','Shop By Category','Your Orders','Wishlist','Best Sellers','My Coupons','Profile','Sign Out','About Us','Contact Us'
  ,'Customer Service',
  ];

  void nextSet(){
    setState(() {if (photoIndex == 0 || photoIndex == 5){ photoIndex++;}
      photoIndex= (photoIndex+1)%6;
    });
  }

  void prevSet(){
    setState(() {if (photoIndex == 0 ||photoIndex == 5 ){ photoIndex--;}
      photoIndex = (photoIndex-1)%6;
    });
  }
  
    Widget _myAnimatedWidget(BuildContext context, {key}){
      return Container(
       key: ValueKey(photoIndex), 
       color: Colors.white,
       height: 71.5,
        child: Row(
        children: photos.sublist(photoIndex,photoIndex+3).map((e) => Container(
        child: Image.asset('$e',width:MediaQuery.of(context).size.width/3 - 32.0,)
         )).toList()                 
         )
        );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          primary: true,
          children: <Widget>[
            Container(
              height: 78.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFAA80000),Colors.redAccent])
              ),
              padding: EdgeInsets.fromLTRB(0.0, 13.0, 0.0, 8.0),
              child: ListTile(
                title: Text('Hello,$name',
                style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.display1,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    leading:
                        CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(photourl),
                         ),
                       ),
                      ),
                      Container(
                        // decoration: BoxDecoration(
                        //   image: DecorationImage(image: AssetImage('assets/images/tilebg.jpg'),fit: BoxFit.fitHeight)
                        // ),
                        child: Column(
                         children: tile.map((e) => Padding(
                           padding: const EdgeInsets.fromLTRB(0.0,4.5,0.0,4.5),
                           child: ListTile(
                              onTap: ()async{
                                switch (e) {
                                  case "Sign Out":
                                    googleSignIn.disconnect();
                                    await FirebaseAuth.instance.signOut().then((value) => 
                                      Navigator.of(context).pushReplacementNamed('/loginpage')
                                    );
                                    break;
                                  case "Profile":
                                    Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context){
                                      return Profilepage(name: name,email: email,photoUrl: photourl,);
                                    }));
                                }
                              },
                              title: Text('$e',
                              style: GoogleFonts.cabin(
                                textStyle: Theme.of(context).textTheme.display1,
                                fontSize: 20,
                                // color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              )
                              )
                             ),
                           ),
                         ).toList())
                        )
                      ],
                     )
                    ),
                    appBar: PreferredSize(
                         preferredSize: Size.fromHeight(60.0),
                         child: AppBar(
                        title: Center(
                          child: Image(image: AssetImage('assets/new.png'),
                          width: 105,
                          height: 120,
                          ),
                        ),
                        flexibleSpace: Container(
                          height: 110,
                          width: double.infinity,
                          color: Colors.black,
                          ),
                          backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        actions: <Widget>[
                          IconButton(
                             icon: Icon(Icons.search,
                             size: 30,
                             ),
                             onPressed: (){
                               Navigator.of(context).push(CupertinoPageRoute(builder: (_)=> SearchPage(
                                 searchSpace: productItems,
                               )));
                              }
                             ),
                           IconButton(
                             icon: Icon(Icons.shopping_cart,
                             ),
                             onPressed: (){
                               Navigator.push(context, CupertinoPageRoute(builder: (context)=> Cart()));
                             }
                             )
                        ],
                      ),
                    ),
              body: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                      Container(
                      height: 200,
                      child: Carousel(
                        animationCurve: Curves.elasticIn,
                        autoplay: false,
                        overlayShadow: false,
                        dotBgColor: Colors.transparent,
                        indicatorBgPadding: 5.0,
                        dotSize: 3.5,
                        images: [Container(
                          width:MediaQuery.of(context).size.width,
                          height: 200.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(fit: BoxFit.fill,image: AssetImage('assets/jns2.jpg'))
                          ),
                        ),
                        Stack(
                            children:<Widget>[ Container(
                            width:MediaQuery.of(context).size.width,
                            height: 200.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(fit: BoxFit.fill,image: AssetImage('assets/images/gift.jpg')), 
                            ),
                          ),
                          Text(' Free \n Delivery \n On \n All \n Products',
                          style: TextStyle(fontFamily: 'Montserrat',foreground:Paint()..shader = LinearGradient(colors: [Colors.blueAccent[400],Colors.black.withOpacity(0.556)]).createShader(Rect.fromLTWH(0.0, 0.0, 150.0, 50.0)),fontSize: 30.0,fontWeight: FontWeight.w600,),
                          )
                          ]
                        ),
                      Container(
                        width:MediaQuery.of(context).size.width,
                        height: 200.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(fit: BoxFit.fill,image: NetworkImage("https://images.unsplash.com/photo-1464349153735-7db50ed83c84?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"))
                        ),
                      ),
                  Container(
                      width:MediaQuery.of(context).size.width,
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(fit: BoxFit.fill,image: NetworkImage("https://images.unsplash.com/photo-1565608444338-315d5fbaeb5e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1355&q=80"))
                      ),
                  ),
                  ]
                  )
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                Container(
                   height: 71.5,
                   color: Colors.white,
                   child: IconButton(icon: Icon(Icons.arrow_left),
                   onPressed: prevSet,splashColor: Colors.transparent)
                  ),
                AnimatedSwitcher(
                  // transitionBuilder: ,
                  duration: Duration(milliseconds: 400),
                      child: _myAnimatedWidget(context)
                ),
                 Container(
                  height: 71.5,
                  color: Colors.white,
                  child: IconButton(icon:Icon(Icons.arrow_right),
                  onPressed: nextSet,splashColor: Colors.transparent)
                 )
                ]
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(7.3,8.0,7.3,8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.black
                  ),
                  child: Center(
                      child: Padding(padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                  ),
                ),
            ),
            categoryItems.length==0?
            Container(
              height: 620,
              child: Center(child: CircularProgressIndicator())
              )
            :Container(
              height: 620,
                 child: GridView.builder(
                   primary: false,
                  itemCount: categoryItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemBuilder: (BuildContext context,index){
                      return Category(index: index, mainCategories: categoryItems,);
                  }
                  )
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(12.0,8.0,8.0,12.0),
                child: Text("They Might Love",
                style: GoogleFonts.lobster(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400
                 ),
                ),
            ),
            Container(
                 height: 4200,
                 child: GridView.builder(
                   primary: false,
                   itemCount: productItems.length,
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                   itemBuilder: (BuildContext context,index){
                        return Singel_prod(
                          prod_name: productItems[index]['name'],
                          prod_picture: productItems[index]['imageUrl'],
                          old_price: productItems[index]['old_price'],
                          price: productItems[index]['price'],
                          description: productItems[index]['description'],
                          diffVariants: productItems[index]['customisable'],
                        );
                      }
                   ),
                 ),
             ]
            ),
              ),
            );
        }
       }
   class Category extends StatefulWidget {
     var mainCategories;
     int index;
     @override
     Category({this.index,this.mainCategories});
     createState() => _CategoryState(index,mainCategories);
   }
   
   class _CategoryState extends State<Category>{
     int index;
     var mainCategories;
     _CategoryState(this.index,this.mainCategories);
     @override
     Widget build(BuildContext context) {
       return Expanded(
         child: GestureDetector(
           onTap: () {
             Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context){
               return CategoryPage(category: widget.mainCategories[index]["category"]);
             }));
           },
             child: Padding(
             padding: const EdgeInsets.all(6.0),
             child: Stack(
                children: <Widget>[
                   Container(
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.8),
                     image: DecorationImage(image: NetworkImage(widget.mainCategories[index]["Images"][0]),fit: BoxFit.cover, ),
                     borderRadius: BorderRadius.circular(10)
                   ),
                 ),
                 Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(10),
                     color: Colors.black45
                   ),
                   child: Center(
                     child: Text(widget.mainCategories[index]['category'],
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 20,
                       fontWeight: FontWeight.w800
                     ),
                    ),
                   )
                  )
                 ]
               ),
             ),
         ),
         );
        }
      }

