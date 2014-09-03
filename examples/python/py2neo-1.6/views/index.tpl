<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-theme.min.css">
    <title>Neo4j Movies</title>
</head>

<body>

<nav class="navbar navbar-inverse" role="navigation">
    <a class="navbar-brand" href="#">Neo4j Movies</a>

    <div class="navbar-header">
        <form id="search" class="navbar-form navbar-left" role="search">
            <div class="form-group">
                <input type="text" name="search" class="form-control" placeholder="Search for Movie Title" value="Matrix">
            </div>
            <button type="submit" class="btn btn-default">Submit</button>
        </form>
    </div>
</nav>

<div class="row">
    <div class="col-md-5 col-md-offset-1">
        <div class="panel panel-default">
            <div class="panel-heading">Search Results</div>
            <table id="results" class="table table-striped table-hover">
                <thead>
                <tr>
                    <th>Movie</th>
                    <th>Released</th>
                    <th>Tagline</th>
                </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
    <div class="col-md-5">
        <div class="panel panel-default">
            <div class="panel-heading" id="title">Details</div>
            <div class="row">
                <div class="col-sm-3">
                    <img src="" id="poster"/>
                </div>
                <div class="col-sm-9">
                    <h5>Crew</h5>
                    <ul id="crew">
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
<style type="text/css">
    .node { stroke: #222; stroke-width: 1.5px; }
    .node.actor { fill: #888; }
    .node.movie { fill: #BBB; }
    .link { stroke: #999; stroke-opacity: .6; stroke-width: 1px; }
</style>
<div class="row">
    <div class="col-md-9 col-md-offset-1" id="graph">
	</div>
</div>	
<script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
<script src="http://d3js.org/d3.v3.min.js" type="text/javascript"></script>
<script type="text/javascript">
    $(function () {
        function showMovie(title) {
            $.get("/movie/" + encodeURIComponent(title),
                    function (data) {
                        if (!data) return;
                        $("#title").text(data.title);
                        $("#poster").attr("src","http://neo4j-contrib.github.io/developer-resources/examples/assets/"+encodeURIComponent(data.title)+".jpg");
                        var $list = $("#crew").empty();
                        data.cast.forEach(function (cast) {
                            $list.append($("<li>" + cast.name + " " +cast.job + (cast.job == "acted"?" as " + cast.role : "") + "</li>"));
                        });
                        // todo viz
                    }, "json");
            return false;
        }
        function search() {
            var query=$("#search").find("input[name=search]").val();
            $.get("/search?q=" + encodeURIComponent(query),
                    function (data) {
                        var t = $("table#results tbody").empty();
                        data.forEach(function (row) {
                            var movie = row.movie;
                            t.append($("<tr><td class='movie'>" + movie.title + "</td><td>" + movie.released + "</td><td>" + movie.tagline + "</td></tr>"))
                        });
                        $("td.movie").click(function() { showMovie($(this).text());})
                    }, "json");
            return false;
        }

        $("#search").submit(search);
        search();
        showMovie("The Matrix");
    })
</script>

<script type="text/javascript">
    var width = 800, height = 600;

    var force = d3.layout.force()
            .charge(-200).linkDistance(30).size([width, height]);

    var svg = d3.select("#graph").append("svg")
            .attr("width", width).attr("height", height);

    d3.json("/graph", function(error, graph) {
		if (error) return;
		
        force.nodes(graph.nodes).links(graph.links).start();

        var link = svg.selectAll(".link")
                .data(graph.links).enter()
                .append("line").attr("class", "link");

        var node = svg.selectAll(".node")
                .data(graph.nodes).enter()
                .append("circle")
                .attr("class", function (d) { return "node "+d.label })
                .attr("r", 10)
                .call(force.drag);

        // html title attribute
        node.append("title")
                .text(function (d) { return d.title; })

//        var text = svg.append("svg:g").selectAll("g").data(force.nodes()).enter().append("svg:g");
//        text.append("svg:text").attr("x", 8).attr("y", "-.31em").attr("class", "text shadow").text(function (d) { return d.title; })

        // force feed algo ticks
        force.on("tick", function() {
            link.attr("x1", function(d) { return d.source.x; })
                    .attr("y1", function(d) { return d.source.y; })
                    .attr("x2", function(d) { return d.target.x; })
                    .attr("y2", function(d) { return d.target.y; });

            node.attr("cx", function(d) { return d.x; })
                    .attr("cy", function(d) { return d.y; });
        });
    });
</script>
</body>
</html>
