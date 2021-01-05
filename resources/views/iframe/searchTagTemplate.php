<html>

<head>
<?php
    $baseUrl = 'http://192.168.10.81/ccintelligence';
?>
<link id="bootstrap-css" rel="stylesheet" href="<?php echo $baseUrl.'/public/js/ccd/bootstrap/bootstrap.min.css'; ?>">
<link rel="stylesheet" href="<?php echo $baseUrl.'/public/css/ccd/style.css'; ?>">
</head>

<body>
<?php
    $baseUrl = 'http://192.168.10.81/ccintelligence';
?>
        <label>FAQ Help Center</label>
        <div id="filecontainer">
            <!-- <input type="text" name="tags" class="" placeholder="Search..."> -->
            <input type="text" class="search_box" id="autocomplete" autocomplete="off" placeholder="Search..." name="search" />
            <span class="input-group-btn">
            <a href="javascript:;" class="btn btn-s btn-info" id="clearBtn" style="width: 50%;margin-top: 10px;border-radius:0px;">Clear</a>
            <a href="javascript:;" class="btn btn-s btn-info" id="searchBtn" style="width: 50%;margin-top: 10px;border-radius:0px;margin-left: 2px">Search</a>
        </span>
        </div>
        <div id="accordion" class="accordion questions-scrollbar scrollbar-outer"></div>
        <script src="<?php echo $baseUrl.'/public/js/ccd/tagify/jquery-3.3.1.min.js'; ?>"></script>
        <!-- Bootstrap -->
        <script src="<?php echo $baseUrl.'/public/js/ccd/bootstrap/bootstrap.min.js'; ?>"></script>
        <!-- Bootstrap -->
        <!-- tagify plugin -->
        <script src="<?php echo $baseUrl.'/public/js/ccd/tagify/tagify.min.js'; ?>" type="text/javascript"></script>
        <script src="<?php echo $baseUrl.'/public/js/ccd/tagify/tagify.polyfills.min.js'; ?>" type="text/javascript"></script>
        <link rel="stylesheet" href="<?php echo $baseUrl.'/public/js/ccd/tagify/tagify.scss'; ?>">
        <!-- tagify plugin -->
        <!-- jQuery Scroll Bar Plugin -->
        <script src="<?php echo $baseUrl.'/public/js/ccd/slimScroll/jquery.scrollbar.js'; ?>" type="text/javascript"></script>
        <link rel="stylesheet" href="<?php echo $baseUrl.'/public/js/ccd/slimScroll/jquery.scrollbar.css'; ?>">
        <!-- jQuery Scroll Bar Plugin -->
        
        <!-- jQuery autocomplete -->
        <script type="text/javascript" src="<?php echo $baseUrl.'/public/js/ccd/autocomplete/jquery.autocomplete.min.js'; ?>"></script>
        <!-- jQuery autocomplete -->
        <script>
            window.onload = function() {
                var remoteUrl = "<?php echo $baseUrl.'/api'?>";
                Array.prototype.forEach.call(window.parent.document.querySelectorAll("link[rel=stylesheet]"), function(link) {
                    var newLink = document.createElement("link");
                    newLink.rel = link.rel;
                    newLink.href = link.href;
                    document.head.appendChild(newLink);
                });
                $('#searchBtn').click(function() {
                    getSearhData();
                });
                $('#clearBtn').click(function() {
                    clearTags();
                });
  
                $('body').delegate('.answerBtn', 'click', function(event) {
                    console.log(event.target.id);
                    getQuestionByID(event.target.id);
                });

                jQuery('.questions-scrollbar').scrollbar();
                
                // $("#autocomplete").keydown(function(event) {
                //     if (event.keyCode == 13){
                //         getSearhData();
                //     }
                // });

                function clearTags() {                    
                    $("#autocomplete").val('');
                    $("#accordion").empty();
                }
                function getSearhData() {
                    if ($("#autocomplete").val()!='') {                        
                        $.ajax({
                            url: remoteUrl + "/remote-get-question-by-tag",
                            type: "post",
                            dataType: 'json',
                            data: {
                                token: "<?php echo $token?>",
                                data: $("#autocomplete").val()
                            },
                            success: function(result) {                                
                                var cat_items = '';
                                $("#accordion").empty();
                                result = jQuery.parseJSON(JSON.stringify(result));
                                console.log(result.length);
                                var index = 0, show='show';
                                $.each(result, function(key, val) {
                                    console.log(key);
                        if(index > 0){
                            show = '';
                        }
                        cat_items += '<div class="card">'+
                        '<div class="card-header" id="heading'+index+'">'+
                        '<h5 class="mb-0">'+
                        '<button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapse'+index+'" aria-expanded="true" aria-controls="collapse'+index+'">'+
                        key+'</button></h5></div>'+
                        '<div id="collapse'+index+'" class="collapse '+show+' fade" aria-labelledby="heading'+index+'" data-parent="#accordion">'+
                        '<div class="card-body">';
                            $.each(val, function(k, value) {
                                cat_items += '<div class="card"><div class="card-body" style="border-bottom: 1px solid rgba(0,0,0,.125)"><h5 class="card-title"><b>'+value.title+'</b></h5>'+
                                '<p class="card-text">'+value.answer.slice(0, 60)+'</p>'+                                
                                '<a class="answerBtn" id="' + value.q_id + '" href="javascript:void(0)" class="ml-3"><strong id="' + value.q_id + '">View More <i class="fa fa-angle-double-right"></i></strong></a>'+
                                '</div></div>';
                            });
                            cat_items += '</div></div></div>';
                            index++;
                        });
                                if (result.length==0) {
                                    cat_items += '<b>No results found</b>';
                                } 
                                $("#accordion").append(cat_items);                                                               
                            }
                        });
                    }
                }

                function getQuestionByID(q_id) {
                    parent.$.colorbox({
                        href: remoteUrl + "/remote-get-question-detail/" + q_id + "?token=" + "<?php echo $token?>",
                        width: 700,
                        height: 335
                    });
                }

                // autocomplete

                // Initialize ajax autocomplete:
                    $('#autocomplete').autocomplete({
                    dataType: 'json',
                    delay: 1000,
                    lookup: function (query, done) {
                        // Do ajax call or lookup locally, when done,
                        // call the callback and pass your results:
                        $.ajax({
                            type: "GET",
                            url: remoteUrl + "/remote-search-tag-list" + '?q=' + query,
                            dataType: "json",
                            beforeSend: function() {
                                $("#autocomplete").addClass('loadinggif');
                            },
                            success: function(data) {                
                                // autoCompleteData = $.parseJSON(data);
                                var result = { suggestions: data };
                                done(result);
                                $("#autocomplete").removeClass('loadinggif');

                            },
                            error: function(XMLHttpRequest, textStatus, errorThrown) {
                                console.log(textStatus);
                                $("#autocomplete").removeClass('loadinggif');
                            }
                        });
                    },
                    onSelect: function (suggestion) {
                        $("#autocomplete").focus();
                        $("#autocomplete").removeClass('loadinggif');
                        getSearhData();
                    }
                });
            };
        </script>
</body>

</html>