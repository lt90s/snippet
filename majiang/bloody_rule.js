function recoverTiles(tiles, AAA, ABC) {
	var tile;
	for (var idx in AAA) {
		tile = AAA[idx]
		tiles[tile] += 3;
	}
	
	for (idx in ABC) {
		tile = ABC[idx]
		tiles[tile] += 1;
		tiles[tile+1] += 1;
		tiles[tile+2] += 1;
	}
}

function isAAAorABC(tiles, i, AAA, ABC) {
	for (var j = i*10+1; j < (i+1)*10; j++) {
		while (tiles[j] > 0) {
			if (tiles[j] >= 3) { // AAA
				tiles[j] -= 3;
				AAA.push(j);
			} else { // ABC
				if ((j%10) > 7 && tiles[j] != 0) {
					return false;
				}
				
				if (tiles[j] > tiles[j+1] || tiles[j] > tiles[j+2]) {
					return false;
				}
				
				for (var k = 0; k < tiles[j]; k++) {
					ABC.push(j);
				}
				
				tiles[j+1] -= tiles[j];
				tiles[j+2] -= tiles[j];
				tiles[j] = 0
			}
		}
	}
	return true
}

function restAAAorABC(tiles) {
	var AAA = [];
	var ABC = [];
	for (var i = 0; i < 3; i++) {
		if (!isAAAorABC(tiles, i, AAA, ABC)) {
			recoverTiles(tiles, AAA, ABC);
			return false;
		}
		recoverTiles(tiles, AAA, ABC);
		AAA = [];
		ABC = [];
	}
	return true
}

var canWin = function(tiles) {
	for (var i = 1; i < tiles.length; i++) {
		var flag = true;
		if (tiles[i] >= 2) {
			tiles[i] -= 2;
			if (!restAAAorABC(tiles)) {
				flag = false;
			}
			tiles[i] += 2;
			if (flag) {
				return true;
			}
		}
	}
	return false;
}

var getAllWinningTiles = function(tiles) {
	var winning = [];
	var helper = function(k) {
		var i = k * 10;
		for(var j = i + 1; j < i + 10; j++) {
			var flag = true;
			
			if (tiles[j] == 0) {
				var x = j % 10;
				if (x > 2 && x < 8 && 
					((tiles[j-2] == 0 || tiles[j-1] == 0) &&   //ABX
					(tiles[j-1] == 0 || tiles[j+1] == 0) &&    //AXC
					(tiles[j+1] == 0 || tiles[j+2] == 0))) {    //XBC
					flag = false;
				}
				
				if (x == 1 && (tiles[j+1] == 0 || tiles[j+1] == 0)) { //XBC
					flag = false;
				}
				
				if (x == 9 && (tiles[j-2] == 0 || tiles[j-1] == 0)) { //ABX
					flag = false;
				}
				
				if (x == 2 && ((tiles[j-1] == 0 || tiles[j+1] == 0) &&        //AXC
									(tiles[j+1] == 0 || tiles[j+2] == 0))) {   //XBC
					flag = false;
				}
				
				if (x == 8 && ((tiles[j-2] == 0 || tiles[j-1] == 0) &&
									(tiles[j-1] == 0 || tiles[j+1] == 0))) {
					flag = false;
				}
			}
			if (flag) {
				tiles[j] += 1;
				if (canWin(tiles)) {
					winning.push(j);
				}
				tiles[j] -= 1;
			}
		}
	}
	
	for (var i = 0; i < 3; i++) {
		helper(i);
	}
	return winning;
}

function test() {
	var data = [ 2,3,4,4,4,4,5,6,7,8,9,9,9]
	var tiles = new Array(30);
	var i;
	for (i = 0; i < tiles.length; i++) {
		tiles[i] = 0;
	}
	for (i = 0; i < data.length; i++) {
		tiles[data[i]] += 1;
	}
	console.log(tiles);
	console.log(getAllWinningTiles(tiles));
	console.log(tiles);
}

test()
