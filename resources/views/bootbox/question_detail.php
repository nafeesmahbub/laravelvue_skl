<style>
#topbar{
	width:75%;
	margin-left: auto ;
    margin-right: auto ;
}
nav {
	float: right;
}
nav li{
	display: inline;
	padding-right: 30px;
}
.logo {
	float:left;
	font-size:30px;
	padding-left:20px;
	padding-top:20px;
}

.box{
	margin-top: 20px;
	width:75%;
	margin-left: auto ;
    margin-right: auto ;
    height: 400px;
}

.blog-post{
	margin-top:20px;
	float:left;
}
.blog-heading{
	font-size: 20px;
	margin-bottom:20px;
	text-align: justify;
}
.sidebar{
	float:right;
}
footer{	
	color: white;	
	margin-left: auto ;    
	margin-right: auto ;	
	font-size:16px;	
	min-height: 50px;	
	padding:20px;	
	background-color: black;	
}
#footer{	
	width:75%;
	margin-left: auto ;    
	margin-right: auto ;
}
</style>
<?php
$baseUrl = 'http://192.168.10.81/ccintelligence';
?>
<div class="box">
	<div class="blog-post">
		<div class="blog-heading">
			<?php echo $question->title;?>
		</div>
        <hr />
		<div class="blog-body">
			<p style="text-align: justify;">
                <?php echo $question->answer;?>
			</p>
            <label>Tags: </label>
            <?php			
            foreach ($tag as $key => $value) { ?>
                <span class="label label-sm label-success"><?php echo $value['name']; ?></span>&nbsp;
            <?php }?>
			<br /><br />
			<div class="form-group form-group-sm">
				<div class="pull-left">					
					<a class="btn btn-sm btn-danger" href="#" onclick="sendFeedback(<?php echo $question->q_id?>, 'N')"> <i class="fa fa-times"></i> Not Useful </a>
					<a class="btn btn-sm btn-success" href="#" onclick="sendFeedback(<?php echo $question->q_id?>, 'U')"> <i class="fa fa-check"></i> Useful </a>
				</div>
        	</div>
		</div>
	</div>
</div>
<script>
function sendFeedback(q_id, feedback){
	$.ajax({
            url: "<?php echo $baseUrl.'/api/questions-feedback?token='.$token?>",
            type: "post",
            dataType: 'json',
            data: {q_id: q_id, feedback: feedback},
            success: function (result) {
				if(result.response_msg.type=='success'){
					alert('Feedback updated successfully.');
				}else{
					alert('Error while processing.');
					console.log(result);
				}
            }
        });

}
</script>
