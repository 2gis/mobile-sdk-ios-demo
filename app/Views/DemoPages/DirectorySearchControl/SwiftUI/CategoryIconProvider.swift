import DGis
import SwiftUI

enum CategoryIconProvider {
	static func image(for categoryID: RubricId) -> SwiftUI.Image? {
		DirectorySearchDemoCategoryIcon(categoryID: categoryID.value)?.image
	}
}

private enum DirectorySearchDemoCategoryIcon: UInt64 {
	case cityGovernment = 1
	case leisureFood = 2
	case computersAppliances = 3
	case cultureReligion = 4
	case medicineBeauty = 5
	case educationCareer = 6
	case advertisingPrinting = 7
	case sportTourism = 8
	case constructionEstateRepair = 9
	case householdServices = 10
	case householdStationery = 11
	case transportCargo = 12
	case metalsFuelChemistry = 13
	case groceriesDrinks = 14
	case equipmentTools = 15
	case petsVet = 746
	case furnitureMaterials = 787
	case legalFinanceBusiness = 969
	case clothesShoes = 1035
	case security = 1621
	case emergencyServices = 5419
	case mallsSpecialtyStores = 6547
	case internetTelecom = 19532
	case electronics = 42863
	case buildingMaterials = 42867
	case textileInterior = 42872
	case automotiveGoods = 42903
	case places = 112663
	case emergency = 122
	case estate1 = 139
	case bars = 159
	case eat = 161
	case coffeshop = 162
	case restaurant = 164
	case burgers = 165
	case zoo = 167
	case recreationpark = 168
	case billiards = 169
	case bowling = 170
	case stakes = 171
	case nightclubs = 173
	case fireworks = 174
	case internet = 176
	case library = 189
	case galleries = 190
	case cinema = 192
	case museums = 193
	case hospital = 201
	case pharmacies = 207
	case glasses = 210
	case dentistry = 222
	case drivingschool = 233
	case childGarden = 237
	case greenhouse = 242
	case school = 245
	case swimmingpools = 261
	case hippodrome = 262
	case gym = 267
	case fitness = 268
	case hotels = 269
	case camp = 270
	case tour = 272
	case agency1 = 275
	case renovation = 276
	case lumber = 281
	case jalousie = 282
	case roof = 284
	case floors = 287
	case windows = 288
	case plumbing = 291
	case dacha = 298
	case hairdressers = 305
	case shoerepair = 307
	case watchesrepair = 308
	case domestic = 311
	case docphoto = 312
	case dryclean = 313
	case safety = 319
	case massmedia = 322
	case vacansy = 327
	case post = 335
	case cellular = 337
	case insurance = 341
	case lawyer = 344
	case child = 345
	case toys = 346
	case books = 347
	case schoolbook = 348
	case office = 352
	case hats = 354
	case furcoat = 355
	case feltboots = 356
	case coveralls = 358
	case beverages = 361
	case chemistry = 362
	case cakes = 363
	case fish = 366
	case drinkwater = 372
	case grocery = 373
	case markets = 376
	case appliances = 379
	case pets = 380
	case stationery = 381
	case cosmetics = 382
	case wedding = 383
	case seeds = 385
	case flowers = 389
	case watches = 390
	case jewelry = 391
	case textile = 392
	case dishes = 396
	case gardensupplies = 397
	case goods = 398
	case carwash = 405
	case chopshop = 406
	case parkingLong = 409
	case fuel = 411
	case tinting = 413
	case cruises1 = 419
	case railroads = 421
	case automotive = 425
	case tire = 427
	case atv = 429
	case repairParts = 430
	case auto = 431
	case icecream = 469
	case coal = 490
	case bank = 492
	case exchange = 498
	case metall = 504
	case nomads = 505
	case gift = 510
	case socials = 520
	case battery = 524
	case bags = 526
	case automatisation = 527
	case taxi = 533
	case aquapark = 537
	case tile = 538
	case fireplace = 548
	case wallpapers = 556
	case meat = 562
	case brick = 579
	case ac = 596
	case tools = 599
	case newBuildings = 603
	case womenswear = 606
	case childclothes = 609
	case yarn = 610
	case stores = 611
	case menswear = 612
	case celebrations = 630
	case football = 633
	case stadiums = 634
	case packaging = 635
	case cellphones = 643
	case phoneacc = 644
	case pcrepair = 650
	case solarium = 651
	case cosmetologist = 652
	case medicalGoods = 660
	case phonerepair = 667
	case b2b = 668
	case languages = 675
	case aquarium = 697
	case industrial = 700
	case cleaning = 709
	case trucking = 721
	case servicesHousing = 758
	case sportGoods = 764
	case footwear = 799
	case fasteners = 805
	case lasertag = 808
	case bicycle = 809
	case sauna = 946
	case photostudio = 1015
	case religion = 1175
	case bijouterie = 1182
	case concrete = 1196
	case foodDelivery = 1203
	case sportnutrition = 1233
	case finances = 1236
	case honey = 1273
	case lawnmower = 3236
	case musical = 4484
	case medicalCenters = 4521
	case transport = 4535
	case ent = 4537
	case bases = 5279
	case manicure = 5603
	case development = 5683
	case guides = 5840
	case outsideAd = 7578
	case tireWorkshop = 7689
	case carRepair = 7693
	case oil = 7900
	case diving = 8151
	case servicesEquip = 8195
	case polygraphy = 8402
	case industrialEquipment = 8743
	case carservice = 9041
	case shashlik = 9220
	case guide = 9281
	case uzbekfood = 9786
	case agency = 9827
	case tow = 9867
	case yachting = 9965
	case doors = 9972
	case furboots = 10377
	case childfurniture = 10566
	case khinkali = 10803
	case xmastree = 10905
	case planetarium = 11647
	case terrarium = 11648
	case icerink = 11974
	case hypermarkets = 12127
	case analyzes = 12211
	case childfootwear = 13100
	case culture = 14967
	case creativity = 15502
	case sushi = 15791
	case oceanarium = 15800
	case costumes = 16491
	case keys = 16610
	case tourism = 16615
	case buuzi = 16677
	case childclubs = 16743
	case pediatric = 16863
	case gasStation = 18547
	case pub = 19290
	case appartments = 19487
	case specials = 19499
	case balcony = 19504
	case cruises = 19601
	case medcheck = 20857
	case karaoke = 21387
	case secondhand = 21448
	case routes = 21493
	case beaches = 24353
	case chemistry1 = 24468
	case ski = 24472
	case salesEquip = 29502
	case award = 47105
	case plants = 47672
	case map = 50850
	case search = 50998
	case livemusic = 51001
	case carting = 51008
	case sales = 51103
	case golf = 51221
	case fishing = 51244
	case police = 51246
	case sport = 51256
	case vote = 51352
	case histnn = 51379
	case pizza = 51459
	case aviators = 51646
	case halal = 51905
	case additionalEducation = 52160
	case dancing = 52236
	case hostels = 52681
	case pancakes = 53599
	case toilets = 53624
	case chinesefood = 55540
	case carwarm = 56428
	case spa = 56759
	case streetcafe = 58871
	case parkingFree = 60340
	case breakfast = 67763
	case martial = 68951
	case vaccination = 69271
	case saltroom = 69989
	case government = 70514
	case helloween = 71642
	case souvenirs = 102026
	case questroom = 110300
	case climbing = 110303
	case pavilion = 110308
	case evCharging = 110320
	case rollerskates = 110335
	case eyesurgery = 110341
	case steamCocktails = 110357
	case fairrides = 110358
	case clothes = 110390
	case schooluniform = 110404
	case trampoline = 110427
	case hunt = 110491
	case snowboard = 111539
	case skilift = 111540
	case waterdelivery = 111544
	case santa = 111573
	case pies = 111594
	case boardgames = 112550
	case parkingShort = 112597
	case soup = 112656
	case cafe = 112658
	case furniture = 112665
	case interesting = 112670
	case swimsuits = 112678
	case servicesEveryday = 112788
	case other = 112862
	case dolphin = 112910
	case buses = 113077
	case mskwinter = 113118
	case namaz = 113291
	case bookmarks = 113292
	case kickscooter = 113466

	init?(categoryID: UInt64) {
		self.init(rawValue: categoryID)
	}

	var image: SwiftUI.Image {
		SwiftUI.Image("category_icons/\(self.assetName)", bundle: .main)
	}

	private var assetName: String {
		switch self {
		case .cityGovernment:
			"government"
		case .leisureFood:
			"Eat"
		case .computersAppliances:
			"pcrepair"
		case .cultureReligion:
			"Culture"
		case .medicineBeauty:
			"Medical centers"
		case .educationCareer:
			"education"
		case .advertisingPrinting:
			"polygraphy"
		case .sportTourism:
			"Sport"
		case .constructionEstateRepair:
			"estate"
		case .householdServices:
			"domestic"
		case .householdStationery:
			"household"
		case .transportCargo:
			"transport"
		case .metalsFuelChemistry:
			"chemistry"
		case .groceriesDrinks:
			"Grocery"
		case .equipmentTools:
			"tools"
		case .emergency:
			"emergency"
		case .estate1:
			"estate-1"
		case .bars:
			"Bars"
		case .eat:
			"Eat"
		case .coffeshop:
			"coffeshop"
		case .restaurant:
			"restaurant"
		case .burgers:
			"Burgers"
		case .zoo:
			"zoo"
		case .recreationpark:
			"recreationpark"
		case .billiards:
			"Billiards"
		case .bowling:
			"bowling"
		case .stakes:
			"stakes"
		case .nightclubs:
			"nightclubs"
		case .fireworks:
			"fireworks"
		case .internet:
			"internet"
		case .library:
			"library"
		case .galleries:
			"galleries"
		case .cinema:
			"cinema"
		case .museums:
			"museums"
		case .hospital:
			"hospital"
		case .pharmacies:
			"pharmacies"
		case .glasses:
			"glasses"
		case .dentistry:
			"dentistry"
		case .drivingschool:
			"drivingschool"
		case .childGarden:
			"child garden"
		case .greenhouse:
			"greenhouse"
		case .school:
			"School"
		case .swimmingpools:
			"swimmingpools"
		case .hippodrome:
			"hippodrome"
		case .gym:
			"gym"
		case .fitness:
			"fitness"
		case .hotels:
			"Hotels"
		case .camp:
			"camp"
		case .tour:
			"tour"
		case .agency1:
			"Agency-1"
		case .renovation:
			"renovation"
		case .lumber:
			"lumber"
		case .jalousie:
			"jalousie"
		case .roof:
			"roof"
		case .floors:
			"floors"
		case .windows:
			"windows"
		case .plumbing:
			"plumbing"
		case .dacha:
			"dacha"
		case .hairdressers:
			"Hairdressers"
		case .shoerepair:
			"shoerepair"
		case .watchesrepair:
			"watchesrepair"
		case .domestic:
			"domestic"
		case .docphoto:
			"docphoto"
		case .dryclean:
			"dryclean"
		case .safety:
			"safety"
		case .massmedia:
			"massmedia"
		case .vacansy:
			"Vacansy"
		case .post:
			"post"
		case .cellular:
			"cellular"
		case .insurance:
			"insurance"
		case .lawyer:
			"lawyer"
		case .child:
			"child"
		case .toys:
			"toys"
		case .books:
			"books"
		case .schoolbook:
			"schoolbook"
		case .office:
			"office"
		case .hats:
			"hats"
		case .furcoat:
			"furcoat"
		case .feltboots:
			"feltboots"
		case .coveralls:
			"coveralls"
		case .beverages:
			"beverages"
		case .chemistry:
			"chemistry"
		case .cakes:
			"cakes"
		case .fish:
			"fish"
		case .drinkwater:
			"drinkwater"
		case .grocery:
			"Grocery"
		case .markets:
			"markets"
		case .appliances:
			"appliances"
		case .pets:
			"pets"
		case .stationery:
			"stationery"
		case .cosmetics:
			"сosmetics"
		case .wedding:
			"wedding"
		case .seeds:
			"seeds"
		case .flowers:
			"flowers"
		case .watches:
			"watches"
		case .jewelry:
			"jewelry"
		case .textile:
			"textile"
		case .dishes:
			"dishes"
		case .gardensupplies:
			"gardensupplies"
		case .goods:
			"goods"
		case .carwash:
			"carwash"
		case .chopshop:
			"chopshop"
		case .parkingLong:
			"parking long"
		case .fuel:
			"fuel"
		case .tinting:
			"tinting"
		case .cruises1:
			"cruises-1"
		case .railroads:
			"railroads"
		case .automotive:
			"Automotive"
		case .tire:
			"tire"
		case .atv:
			"atv"
		case .repairParts:
			"repair parts"
		case .auto:
			"auto"
		case .icecream:
			"Icecream"
		case .coal:
			"coal"
		case .bank:
			"bank"
		case .exchange:
			"exchange"
		case .metall:
			"metall"
		case .nomads:
			"Nomads"
		case .gift:
			"Gift"
		case .socials:
			"socials"
		case .battery:
			"battery"
		case .bags:
			"bags"
		case .automatisation:
			"automatisation"
		case .taxi:
			"taxi"
		case .aquapark:
			"aquapark"
		case .tile:
			"tile"
		case .fireplace:
			"fireplace"
		case .wallpapers:
			"wallpapers"
		case .meat:
			"meat"
		case .brick:
			"brick"
		case .ac:
			"ac"
		case .tools:
			"tools"
		case .newBuildings:
			"New buildings"
		case .womenswear:
			"womenswear"
		case .childclothes:
			"childclothes"
		case .yarn:
			"yarn"
		case .stores:
			"Stores"
		case .menswear:
			"menswear"
		case .celebrations:
			"celebrations"
		case .football:
			"football"
		case .stadiums:
			"stadiums"
		case .packaging:
			"packaging"
		case .cellphones:
			"cellphones"
		case .phoneacc:
			"phoneacc"
		case .pcrepair:
			"pcrepair"
		case .solarium:
			"solarium"
		case .cosmetologist:
			"cosmetologist"
		case .medicalGoods:
			"medical-goods"
		case .phonerepair:
			"phonerepair"
		case .b2b:
			"b2b"
		case .languages:
			"languages"
		case .aquarium:
			"aquarium"
		case .industrial:
			"industrial"
		case .cleaning:
			"cleaning"
		case .trucking:
			"trucking"
		case .servicesHousing:
			"Services"
		case .sportGoods:
			"sport-goods"
		case .footwear:
			"footwear"
		case .fasteners:
			"fasteners"
		case .lasertag:
			"lasertag"
		case .bicycle:
			"Bicycle"
		case .sauna:
			"sauna"
		case .photostudio:
			"photostudio"
		case .religion:
			"religion"
		case .bijouterie:
			"bijouterie"
		case .concrete:
			"concrete"
		case .foodDelivery:
			"food delivery"
		case .sportnutrition:
			"sportnutrition"
		case .finances:
			"finances"
		case .honey:
			"honey"
		case .lawnmower:
			"lawnmower"
		case .musical:
			"Musical"
		case .medicalCenters:
			"Medical centers"
		case .transport:
			"transport"
		case .ent:
			"ENT"
		case .bases:
			"bases"
		case .manicure:
			"manicure"
		case .development:
			"development"
		case .guides:
			"guides"
		case .outsideAd:
			"outside ad"
		case .tireWorkshop:
			"Tire workshop"
		case .carRepair:
			"car repair"
		case .oil:
			"oil"
		case .diving:
			"diving"
		case .servicesEquip:
			"services-equip"
		case .polygraphy:
			"polygraphy"
		case .industrialEquipment:
			"industrial equipment"
		case .carservice:
			"Carservice"
		case .shashlik:
			"shashlik"
		case .guide:
			"Guide"
		case .uzbekfood:
			"Uzbekfood"
		case .agency:
			"Agency"
		case .tow:
			"tow"
		case .yachting:
			"yachting"
		case .doors:
			"doors"
		case .furboots:
			"furboots"
		case .childfurniture:
			"childfurniture"
		case .khinkali:
			"Khinkali"
		case .xmastree:
			"xmastree"
		case .planetarium:
			"planetarium"
		case .terrarium:
			"terrarium"
		case .icerink:
			"icerink"
		case .hypermarkets:
			"Hypermarkets"
		case .analyzes:
			"Analyzes"
		case .childfootwear:
			"childfootwear"
		case .culture:
			"Culture"
		case .creativity:
			"creativity"
		case .sushi:
			"sushi"
		case .oceanarium:
			"oceanarium"
		case .costumes:
			"costumes"
		case .keys:
			"keys"
		case .tourism:
			"tourism"
		case .buuzi:
			"Buuzi"
		case .childclubs:
			"childclubs"
		case .pediatric:
			"pediatric"
		case .gasStation:
			"gas station"
		case .pub:
			"Pub"
		case .appartments:
			"appartments"
		case .specials:
			"specials"
		case .balcony:
			"Balcony"
		case .cruises:
			"cruises"
		case .medcheck:
			"Medcheck"
		case .karaoke:
			"karaoke"
		case .secondhand:
			"secondhand"
		case .routes:
			"Routes"
		case .beaches:
			"beaches"
		case .chemistry1:
			"chemistry-1"
		case .ski:
			"ski"
		case .salesEquip:
			"sales-equip"
		case .award:
			"Award"
		case .plants:
			"plants"
		case .map:
			"Map"
		case .search:
			"Search"
		case .livemusic:
			"livemusic"
		case .carting:
			"carting"
		case .sales:
			"sales"
		case .golf:
			"golf"
		case .fishing:
			"fishing"
		case .police:
			"police"
		case .sport:
			"Sport"
		case .vote:
			"vote"
		case .histnn:
			"HistNN"
		case .pizza:
			"Pizza"
		case .aviators:
			"aviators"
		case .halal:
			"halal"
		case .additionalEducation:
			"additional-education"
		case .dancing:
			"dancing"
		case .hostels:
			"hostels"
		case .pancakes:
			"pancakes"
		case .toilets:
			"Toilets"
		case .chinesefood:
			"chinesefood"
		case .carwarm:
			"carwarm"
		case .spa:
			"spa"
		case .streetcafe:
			"streetcafe"
		case .parkingFree:
			"Parking free"
		case .breakfast:
			"Breakfast"
		case .martial:
			"martial"
		case .vaccination:
			"Vaccination"
		case .saltroom:
			"saltroom"
		case .government:
			"government"
		case .helloween:
			"helloween"
		case .souvenirs:
			"souvenirs"
		case .questroom:
			"questroom"
		case .climbing:
			"climbing"
		case .pavilion:
			"pavilion"
		case .evCharging:
			"ev-charging"
		case .rollerskates:
			"rollerskates"
		case .eyesurgery:
			"eyesurgery"
		case .steamCocktails:
			"steam cocktails"
		case .fairrides:
			"fairrides"
		case .clothes:
			"clothes"
		case .schooluniform:
			"schooluniform"
		case .trampoline:
			"trampoline"
		case .hunt:
			"hunt"
		case .snowboard:
			"snowboard"
		case .skilift:
			"skilift"
		case .waterdelivery:
			"waterdelivery"
		case .santa:
			"santa"
		case .pies:
			"Pies"
		case .boardgames:
			"boardgames"
		case .parkingShort:
			"parking short"
		case .soup:
			"soup"
		case .cafe:
			"cafe"
		case .furniture:
			"furniture"
		case .interesting:
			"Interesting"
		case .swimsuits:
			"Swimsuits"
		case .servicesEveryday:
			"services"
		case .other:
			"Other"
		case .dolphin:
			"dolphin"
		case .buses:
			"buses"
		case .mskwinter:
			"mskwinter"
		case .namaz:
			"Namaz"
		case .bookmarks:
			"Bookmarks"
		case .kickscooter:
			"Kickscooter"
		case .furnitureMaterials:
			"furniture"
		case .legalFinanceBusiness:
			"finances"
		case .clothesShoes:
			"clothes"
		case .security:
			"safety"
		case .emergencyServices:
			"emergency"
		case .mallsSpecialtyStores:
			"Stores"
		case .internetTelecom:
			"internet"
		case .electronics:
			"appliances"
		case .buildingMaterials:
			"brick"
		case .textileInterior:
			"textile"
		case .automotiveGoods:
			"Automotive"
		case .petsVet:
			"pets"
		case .places:
			"Map"
		}
	}
}
