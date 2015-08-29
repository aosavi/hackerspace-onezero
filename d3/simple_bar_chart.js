// Making some fictional data
var data = [[5,3], [10,17], [15,4], [2,8]];


// deciding on the margins and height and width
var margin = {top: 20, right: 15, bottom: 60, left: 60}
  , width = 650 - margin.left - margin.right
  , height = 500 - margin.top - margin.bottom;

// select the body and append the svg element with widt and height
var chart = d3.select('.barChart').append('svg')
	.attr('width', width + margin.right + margin.left)
	.attr('height', height + margin.top + margin.bottom)
	.attr('class', 'chart')
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Defining the scales. Use linear transformations    
var x = d3.scale.linear()
  .domain([0, d3.max(data, function(d) { return d[0]; })])
  .range([ 0, width ]);

var y = d3.scale.linear()
  .domain([0, d3.max(data, function(d) { return d[1]; })])
  .range([ height, 0 ]);

// its often convention to put making a grouping element directly in the svg
var main = chart.append('g')
  .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
  .attr('width', width)
  .attr('height', height)
  .attr('class', 'main')   
        
// draw the x axis
var xAxis = d3.svg.axis()
  .scale(x)
  .orient('bottom');

// append the x axis
main.append('g')
  .attr('transform', 'translate(0,' + height + ')')
  .attr('class', 'axis main')
  .call(xAxis);

 // draw the y axis
var yAxis = d3.svg.axis()
  .scale(y)
  .orient('left');

// append the y axis
main.append('g')
  .attr('transform', 'translate(0,0)')
  .attr('class', 'axis main')
  .call(yAxis);

var g = main.append("svg:g"); 
    
g.selectAll("scatter-dots")
  .data(data)
  .enter().append("svg:circle")
  .attr("cx", function (d,i) { return x(d[0]); } )
  .attr("cy", function (d) { return y(d[1]); } )
  .attr("r", 8);