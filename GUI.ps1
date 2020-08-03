############  BYPASS SECURITY POLICY ##########
#PowerShell.exe -ExecutionPolicy Bypass

##############  FILE LOCATION  #####################
## folder location = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals'
$database = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals\DB.txt'
$dailyPacking = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals\dailyPacking.txt'
$dailyReceive = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals\dailyReceive.txt'
$dailyCorrection = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals\corrections.txt'
$unitQuant = 'C:\Users\ehe\Desktop\Archives\INVENTORY\Internals\unitQuant.txt'

##############  GLOBAL VARIABLES  #####################
$numOfBarcodeDigits = 12
$numOfBoxDigits = 14
$outPutFields = "BOX BARCODE :  ", "SINGLE-UNIT BARCODE :  ", "MODEL NAME :  ", "LOCATION :  ", "Total Pieces :  "
$global:curOutPutFieldsIndex = 0

### MAIN FORM SETUP
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Ascent Inventory Database'
$main_form.Width = 710
$main_form.Height = 670
$main_form.AutoSize = $true
$main_form.Font = [System.Drawing.Font]::new("Calibri", 16, [System.Drawing.FontStyle]::Bold)
$main_form.BackColor = "Gray"


### ADD MAIN FORM INTRO TEXT HERE
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "            INVENTORY TRACKING SYSTEM`n
    -----------------------------------------------------`n"

$Label.Location  = New-Object System.Drawing.Point(145,80)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

$B_checkInventory = New-Object System.Windows.Forms.Button
$B_checkInventory.Location = New-Object System.Drawing.Size(200,200)
$B_checkInventory.Size = New-Object System.Drawing.Size(300,80)
$B_checkInventory.Text = " Check Inventory"
$main_form.Controls.Add($B_checkInventory)


$B_packInventory = New-Object System.Windows.Forms.Button
$B_packInventory.Location = New-Object System.Drawing.Size(200,280)
$B_packInventory.Size = New-Object System.Drawing.Size(300,80)
$B_packInventory.Text = " Pack Inventory"
$main_form.Controls.Add($B_packInventory)

$B_receiveInventory = New-Object System.Windows.Forms.Button
$B_receiveInventory.Location = New-Object System.Drawing.Size(200,360)
$B_receiveInventory.Size = New-Object System.Drawing.Size(300,80)
$B_receiveInventory.Text = "Receive Inventory"
$main_form.Controls.Add($B_receiveInventory)

$B_reportIssue = New-Object System.Windows.Forms.Button
$B_reportIssue.Location = New-Object System.Drawing.Size(200,440)
$B_reportIssue.Size = New-Object System.Drawing.Size(300,80)
$B_reportIssue.Text = "Report Issue"
$main_form.Controls.Add($B_reportIssue)

$BQ = New-Object System.Windows.Forms.Button
$BQ.Location = New-Object System.Drawing.Size(590,530)
$BQ.Size = New-Object System.Drawing.Size(70,50)
$BQ.Text = "QUIT"
$main_form.Controls.Add($BQ)

### ADD 1st BUTTON FUNCTION
$B_checkInventory.Add_Click({
    
    $cf = childFormGen
    $cf.Text = 'Check Inventory'
    $barCodeBox = barCodeBoxGen
    $cf.Controls.Add($barCodeBox)

    $barCode_Label = New-Object System.Windows.Forms.Label
    $barCode_Label.Text = "Enter Box Barcode / Product Barcode / Model Name "
    $barCode_Label.Location  = New-Object System.Drawing.Point(138,80)
    $barCode_Label.AutoSize = $true
    $cf.Controls.Add($barCode_Label)

    $result_Label = resultLabelGen
    $cf.Controls.Add($result_Label)

    $confirmButton = confirmButtonGen
    $cf.Controls.Add($confirmButton)

    $back_Button = New-Object System.Windows.Forms.Button
    $back_Button.Location = New-Object System.Drawing.Point(350,380)
    $back_Button.Size = New-Object System.Drawing.Size(100,50)
    $back_Button.Text = "BACK"
    $back_Button.Visible = $true
    $cf.Controls.Add($back_Button)

    $back_Button.Add_Click({
        $cf.close()
    })

    $reset_Button = New-Object System.Windows.Forms.Button
    $reset_Button.Location = New-Object System.Drawing.Point(230,380)
    $reset_Button.Size = New-Object System.Drawing.Size(100,50)
    $reset_Button.Text = "RESET"
    $reset_Button.Visible = $false
    $cf.Controls.Add($reset_Button)

    $reset_Button.Add_Click({
        $barCodeBox.Text = ''
        $result_Label.Text = ''
        $reset_Button.Visible = $false
        $confirmButton.Visible = $true
    })


    $confirmButton.Add_Click({

        ### processing barCode scanned
        $isFound = $false
        $inputString = $barCodeBox.Text.toString() 
	    $numOfCharsMatched = $inputString.length
        $confirmButton.Visible = $false

        #if there are 14 digits are the 1st char is a digit, then it's a box barcode
        

            if (($numOfCharsMatched -eq $numOfBoxDigits) -AND ($inputString[0] -match "\d")){
                $searchString = $barCodeBox.Text.Substring(1,12)
            }else{
                $searchString = $barCodeBox.Text
            }
            foreach($LINE in Get-Content -path $database){

			        if ($LINE -match $searchString){
				        $isFound = $true 
                        $lineArrray = $LINE.toCharArray()
                        $result_Label.Text += $outPutFields[$curOutPutFieldsIndex]

                        for ($index = 0; $index -le $lineArrray.length; $index++){

                            if ($lineArrray[$index] -eq "`t"){
                                $result_Label.Text += "`n"
                                $curOutPutFieldsIndex++
                                $result_Label.Text += $outPutFields[$curOutPutFieldsIndex]
                            }
 
                            $result_Label.Text += $lineArrray[$index]
                        }
                    $curOutPutFieldsIndex = 0
				    break
			    }
		    }

		    if ($isFound -eq $false){
                $result_Label.Text = "Barcode is NOT FOUND in database.`n"
		    }
            $reset_Button.Visible = $true
            $back_Button.Visible = $true
    })
    $cf.ShowDialog()
})


### ADD 2nd BUTTON FUNCTION
$B_packInventory.Add_Click({
   

    ### FORM SET UP
    $pf = childFormGen
    $pf.Text = 'Pack Inventory'

    $PO_Label = New-Object System.Windows.Forms.Label
    $PO_Label.Text = "Please Enter the Purchase Order Number"
    $PO_Label.Location  = New-Object System.Drawing.Point(180,92)
    $PO_Label.AutoSize = $true
    $pf.Controls.Add($PO_Label)
    
    $PO_BOX = New-Object System.Windows.Forms.TextBox
    $PO_BOX.Location = New-Object System.Drawing.Point(240,135)
    $PO_BOX.Size = New-Object System.Drawing.Size(200,100)
    $pf.Controls.Add($PO_BOX)

    $customer_Label = New-Object System.Windows.Forms.Label
    $customer_Label.Text = "Please Enter the Name of the Customer "
    $customer_Label.Location  = New-Object System.Drawing.Point(180,200)
    $customer_Label.AutoSize = $true
    $pf.Controls.Add($customer_Label)
    				
    $customer_BOX = New-Object System.Windows.Forms.TextBox
    $customer_BOX.Location = New-Object System.Drawing.Point(240,238)
    $customer_BOX.Size = New-Object System.Drawing.Size(200,100)
    $pf.Controls.Add($customer_BOX)

    $reset_Button = New-Object System.Windows.Forms.Button
    $reset_Button.Location = New-Object System.Drawing.Point(145,330)
    $reset_Button.Size = New-Object System.Drawing.Size(100,50)
    $reset_Button.Text = "RESET"
    $pf.Controls.Add($reset_Button)

    $reset_Button.Add_Click({
        $customer_BOX.Text = ''
        $PO_BOX.Text = ''
        $PO_BOX.focus()
    })

    $back_Button = New-Object System.Windows.Forms.Button
    $back_Button.Location = New-Object System.Drawing.Point(430,330)
    $back_Button.Size = New-Object System.Drawing.Size(100,50)
    $back_Button.Text = "BACK"
    $pf.Controls.Add($back_Button)

    $back_Button.Add_Click({
        $pf.close()
    })


    $checkPackingList_Button = New-Object System.Windows.Forms.Button
    $checkPackingList_Button.Location = New-Object System.Drawing.Point(200,400)
    $checkPackingList_Button.Size = New-Object System.Drawing.Size(300,40)
    $checkPackingList_Button.Text = "Check Entire Packing List"
    $pf.Controls.Add($checkPackingList_Button)

    $checkPackingList_Button.Add_Click({
            ### FORM SET UP
        $cf = New-Object System.Windows.Forms.Form
        $cf.Text = 'OPTION 4'
        $cf.Width = 880
        $cf.Height = 600
        $cf.AutoSize = $false
        $cf.Font = [System.Drawing.Font]::new("Calibri", 16, [System.Drawing.FontStyle]::Bold)
        $cf.BackColor = "Gray"
        $cf.AutoScroll = $true

         $result_Label = New-Object System.Windows.Forms.Label
	    $result_Label.Location  = New-Object System.Drawing.Point(50,20)
        $result_Label.AutoSize = $true

        foreach($LINE in Get-Content $dailyPacking){
            $result_Label.Text += "`n"
            $lineArrray = $LINE.toCharArray()
            for ($index = 0; $index -le $lineArrray.length; $index++){
                if ($lineArrray[$index] -eq "`t"){
                    $result_Label.Text += "    "
                }
              $result_Label.Text += $lineArrray[$index]
            }
             #$result_Label.Text += "`n"
         }
        $result_Label.Text += "`n`n"
        $cf.Controls.Add($result_Label)
        $cf.ShowDialog()
    })


    $finish_Button = New-Object System.Windows.Forms.Button
    $finish_Button.Location = New-Object System.Drawing.Point(290,330)
    $finish_Button.Size = New-Object System.Drawing.Size(100,50)
    $finish_Button.Text = "FINISH"
    $pf.Controls.Add($finish_Button)

    $finish_Button.Add_Click({
         echo "`n" >> $dailyPacking
         echo ("Purchase Order: " + $PO_Box.Text) >> $dailyPacking 
         echo ("Customer: " + $customer_BOX.Text) >> $dailyPacking
         echo "----------------------------------------------------" >> $dailyPacking
         $cf = childFormGen
         $cf.Text = 'OPTION 2'
         $barCodeBox = barCodeBoxGen
         $cf.Controls.Add($barCodeBox)

         $barCode_Label = New-Object System.Windows.Forms.Label
         $barCode_Label.Text = "Enter Box Barcode / Product Barcode"
         $barCode_Label.Location  = New-Object System.Drawing.Point(175,80)
         $barCode_Label.AutoSize = $true
         $cf.Controls.Add($barCode_Label)

         $total_Label = New-Object System.Windows.Forms.Label
         $total_Label.Text = "Enter number of units"
         $total_Label.Location  = New-Object System.Drawing.Point(235,180)
         $total_Label.AutoSize = $true
         $cf.Controls.Add($total_Label)
		
         $total_Box = New-Object System.Windows.Forms.TextBox
         $total_Box.Location = New-Object System.Drawing.Point(245,220)
         $total_Box.Size = New-Object System.Drawing.Size(200,30)
         $cf.Controls.Add($total_Box)

         $result_Label = New-Object System.Windows.Forms.Label
	     $result_Label.Location  = New-Object System.Drawing.Point(230,280)
         $result_Label.AutoSize = $true
         $cf.Controls.Add($result_Label)


         ##### 3 option buttons here ####
         ### confirm
         $enter_Button = New-Object System.Windows.Forms.Button
         $enter_Button.Location = New-Object System.Drawing.Point(200,390)
         $enter_Button.Size = New-Object System.Drawing.Size(115,48)
         $enter_Button.Text = "Enter"
         $cf.Controls.Add($enter_Button)

         $cancel_Button = New-Object System.Windows.Forms.Button
         $cancel_Button.Location = New-Object System.Drawing.Point(95,390)
         $cancel_Button.Size = New-Object System.Drawing.Size(100,48)
         $cancel_Button.Text = "Cancel"
         $cancel_Button.Visible = $false
         $cf.Controls.Add($cancel_Button)

         $cancel_Button.Add_Click({
            $cancel_Button.Visible = $false
            $nextItem_Button.Visible = $false
            $enter_Button.Visible = $true
            $barCodeBox.Text = ''
            $total_Box.Text = ''
            $result_Label.Text = ''
            $barCodeBox.focus()
         })

         ### next item button
         $nextItem_Button = New-Object System.Windows.Forms.Button
         $nextItem_Button.Location = New-Object System.Drawing.Point(200,390)
         $nextItem_Button.Size = New-Object System.Drawing.Size(141,48)
         $nextItem_Button.Text = "Confirm/Next"
         $nextItem_Button.visible = $false
         $cf.Controls.Add($nextItem_Button)
        
          #### next item button 
         $nextItem_Button.Add_Click({

                $nextItem_Button.Visible = $false
                $cancel_Button.Visible = $false
                $enter_Button.Visible = $true
                
			    echo ("Date: " + (Get-Date)) >> $dailyPacking
		        echo ("Description: " + $barCodeBox.Text) >> $dailyPacking
                echo $result_Label.Text >> $dailyPacking
                echo "`n" >> $dailyPacking

                $total_Box.Text = ''
                $barCodeBox.Text = ''
                $result_Label.Text = ''
                $barCodeBox.focus()
          })

         ##  back to the prev page button
         $prev_Button = New-Object System.Windows.Forms.Button
         $prev_Button.Location = New-Object System.Drawing.Point(390,390)
         $prev_Button.Size = New-Object System.Drawing.Size(120,48)
         $prev_Button.Text = "Back"
         $prev_Button.Visible = $true
         $cf.Controls.Add($prev_Button)

         $prev_Button.Add_Click({
              $cf.close()
         })

         $enter_Button.Add_Click({
             ### PROCESSING BARCODE
             $isFound = $false
	         $numOfCharsMatched = $barCodeBox.Text.toString().length
             $enter_Button.Visible = $false

             if ($total_Box.Text -notmatch "\d"){
                  $result_Label.Text = "Please cancel and enter number only."
                  $cancel_Button.Visible = $true
             }
             elseif ($numOfCharsMatched -ne $numOfBarcodeDigits -AND $numOfCharsMatched -ne $numOfBoxDigits ){
                 $result_Label.Text = "Barcode length is wrong.`nPlease cancel and re-scan."
                 $cancel_Button.Visible = $true
             }
             else{
                 $cancel_Button.Visible = $true
                 $nextItem_Button.Visible = $true

                if ($numOfCharsMatched -eq $numOfBoxDigits){
                    $searchString = $barCodeBox.Text.Substring(1,12)
                }else{
                    $searchString = $barCodeBox.Text
                }

                foreach($LINE in Get-Content -path $unitQuant){
			        if ($LINE -match $searchString){
				          $isFound = $true
                          $tokensArr = $LINE -split "`t"
                          $numOfTokens = $tokensArr.Count
                          $unitQuantity = $tokensArr[$numOfTokens - 1]

                        if ($unitQuantity -notmatch "\d"){
                            $result_Label.Text = "Unknown Per-Unit Quantity.`nRe-scan or coordinate with front office."
                            break
                        }else{

                            if ($numOfCharsMatched -eq $numOfBoxDigits)
                            {
                                 $result_Label.Text += "Type: Box"
                                 $result_Label.Text += " ($unitQuantity pieces)"
                            }else{
                                 $result_Label.Text += "Type: Single-Item"
                            }
                            
                            $result_Label.Text += "`nQuantity Packed:  " 
                            $result_Label.Text += $total_Box.Text
                            $result_Label.Text += "`nTotal Pieces:  " 
                            $result_Label.Text += ([int]($total_Box.Text) * ($unitQuantity))


			                #echo ("Date: " + (Get-Date)) >> $dailyPacking
			                #echo ("Description: " + ($barCodeBox.Text)) >> $dailyPacking
                            #echo $result_Label.Text >> $dailyPacking
                            #echo "`n" >> $dailyPacking
				            break
                        }
			        }
		        }

		        if ($isFound -eq $false){
                    $result_Label.Text = 
                        "Item NOT FOUND in the database.`nCheck your barcode and re-scan.`nOr, coordinate with the front office."
                    $cancel_Button.Visible = $true
                    $nextItem_Button.Visible = $false
		        }
            }
         })

         $cf.ShowDialog()
        
       })

    $pf.ShowDialog()
})


$B_receiveInventory.Add_Click({
   
    ### FORM SET UP
    $cf = childFormGen
    $cf.Text = 'Receive Inventory'

    $barCode_Label = New-Object System.Windows.Forms.Label
    $barCode_Label.Text = "  Please scan or enter the barcode of your intakes"
    $barCode_Label.Location  = New-Object System.Drawing.Point(140,55)
    $barCode_Label.AutoSize = $true
    $cf.Controls.Add($barCode_Label)

    $units_Label = New-Object System.Windows.Forms.Label
    $units_Label.Text = "  Total Units (in Single-Unit or Box): "
    $units_Label.Location  = New-Object System.Drawing.Point(175,135)
    $units_Label.AutoSize = $true
    $cf.Controls.Add($units_Label)

    $location_Label = New-Object System.Windows.Forms.Label
    $location_Label.Text = "  Designated Inventory Location: "
    $location_Label.Location  = New-Object System.Drawing.Point(190,210)
    $location_Label.AutoSize = $true
    $cf.Controls.Add($location_Label)

    $barCodeBox = New-Object System.Windows.Forms.TextBox
    $barCodeBox.Location = New-Object System.Drawing.Point(240,90)
    $barCodeBox.Size = New-Object System.Drawing.Size(200,30)
    $cf.Controls.Add($barCodeBox)
			
    $total_Box = New-Object System.Windows.Forms.TextBox
    $total_Box.Location = New-Object System.Drawing.Point(240,165)
    $total_Box.Size = New-Object System.Drawing.Size(200,30)
    $cf.Controls.Add($total_Box)

    $location_BOX = New-Object System.Windows.Forms.TextBox
    $location_BOX.Location = New-Object System.Drawing.Point(240,240)
    $location_BOX.Size = New-Object System.Drawing.Size(200,30)
    $cf.Controls.Add($location_Box)

    $checkReceivingList_Button = New-Object System.Windows.Forms.Button
    $checkReceivingList_Button.Location = New-Object System.Drawing.Point(200,420)
    $checkReceivingList_Button.Size = New-Object System.Drawing.Size(300,40)
    $checkReceivingList_Button.Text = "Check Entire Receiving List"
    $cf.Controls.Add($checkReceivingList_Button)

    $enter_Button = New-Object System.Windows.Forms.Button
    $enter_Button.Location = New-Object System.Drawing.Point(300,350)
    $enter_Button.Size = New-Object System.Drawing.Size(100,40)
    $enter_Button.Text = "ENTER"
    $cf.Controls.Add($enter_Button)

    $confirm_Button = New-Object System.Windows.Forms.Button
    $confirm_Button.Location = New-Object System.Drawing.Point(50,150)
    $confirm_Button.Size = New-Object System.Drawing.Size(100,40)
    $confirm_Button.Text = "Confirm"
    $confirm_Button.Visible = $false
    $cf.Controls.Add($confirm_Button)

    $confirm_Button.Add_Click({
         $receiveDate = Get-Date
         echo "`n  Date: $receiveDate" >> $dailyReceive
         echo $result_Label.Text >> $dailyReceive
         $barCodeBox.Text = ''
         $total_Box.Text = ''
         $location_BOX.Text = ''
        $enter_Button.Visible= $true
        $result_Label.Text = ''
        $reset_Button.Text = 'Reset'
        $confirm_Button.Visible = $false
        $barCodeBox.Focus()
   })

    $reset_Button = New-Object System.Windows.Forms.Button
    $reset_Button.Location = New-Object System.Drawing.Point(50,200)
    $reset_Button.Size = New-Object System.Drawing.Size(100,40)
    $reset_Button.Text = "Cancel"
    $cf.Controls.Add($reset_Button)

    $reset_Button.Add_Click({
        $barCodeBox.Text = ''
        $total_Box.Text = ''
        $location_BOX.Text = ''
        $enter_Button.Visible= $true
        $result_Label.Text = ''
        $barCodeBox.Focus()
    })


    $back_Button = New-Object System.Windows.Forms.Button
    $back_Button.Location = New-Object System.Drawing.Point(50,250)
    $back_Button.Size = New-Object System.Drawing.Size(100,40)
    $back_Button.Text = "Back"
    $cf.Controls.Add($back_Button)

    $back_Button.Add_Click({
        $cf.close()
    })

    $checkReceivingList_Button.Add_Click({
          ### FORM SET UP
        $pf = New-Object System.Windows.Forms.Form
        $pf.Width = 880
        $pf.Height = 600
        $pf.AutoSize = $false
        $pf.Font = [System.Drawing.Font]::new("Calibri", 16, [System.Drawing.FontStyle]::Bold)
        $pf.BackColor = "Gray"
        $pf.AutoScroll = $true

        $result_Label = New-Object System.Windows.Forms.Label
	    $result_Label.Location  = New-Object System.Drawing.Point(50,20)
        $result_Label.AutoSize = $true

        foreach($LINE in Get-Content $dailyReceive){
            $result_Label.Text += "`n"
            $lineArrray = $LINE.toCharArray()
            for ($index = 0; $index -le $lineArrray.length; $index++){
                 if ($lineArrray[$index] -eq "`t"){
                    $result_Label.Text += "    "
                 }
                 $result_Label.Text += $lineArrray[$index]
            }
        }
         $result_Label.Text += "`n`n"
         $pf.Controls.Add($result_Label)
         $pf.ShowDialog()
    })

    
     $result_Label = New-Object System.Windows.Forms.Label
	 $result_Label.Location  = New-Object System.Drawing.Point(140,300)
     $result_Label.AutoSize = $true
     $cf.Controls.Add($result_Label)


    $enter_Button.Add_Click({
       
         $reset_Button.Text = 'Cancel'
         $reset_Button.Add_Click({
            $reset_Button.Text = 'Reset'
            $confirm_Button.Visible = $false
         })

         $enter_Button.Visible = $false
         

         $isFound = $false
	     $numOfCharsMatched = $barCodeBox.Text.toString().length
         $enter_Button.Visible = $false

         
         if ($total_Box.Text -notmatch "\d"){
              $result_Label.Text = "Please cancel and enter number only."
         }
         elseif ($numOfCharsMatched -ne $numOfBarcodeDigits -AND $numOfCharsMatched -ne $numOfBoxDigits ){
             $result_Label.Text = "    Barcode length is wrong, cancel and re-scan"
         }
         else{
            # if box barcode is scanned = 14 digits
            if ($numOfCharsMatched -eq $numOfBoxDigits){
                $searchString = $barCodeBox.Text.Substring(1,12)
            }else{
                $searchString = $barCodeBox.Text
            }

            foreach($LINE in Get-Content -path $database){
			    if ($LINE -match $searchString){
				    $isFound = $true
                    $unitQuant = getUnitQuan($searchString)

                    if ($unitQuant -notmatch "\d"){
                        $result_Label.Text = "Quantity Per Unit Unknown, `NPlease use REPORT option on the main page."
                        break
                    }else{
                       ## confirm option only avaialble when item is found and per unit info avaialable
                        $confirm_Button.Visible = $true
                        $result_Label.Text += "  Ref: $LINE" 
                        $receiveRecord = "`n  Total Pieces  =  " +  ([int]($total_Box.Text) * ($unitQuant))
                        $result_Label.Text += ($receiveRecord) 
                        $result_Label.Text += "  ( " + $total_Box.Text + " unit  x  " + $unitQuant + " piece per unit )"
                        $locationInfo = " Designated Location:  " + $location_Box.Text
                        $result_Label.Text += " `n $locationInfo"
				        break
                    }
			    }
		    }

		    if ($isFound -eq $false){
                $result_Label.Text = 
                    "  Item NOT FOUND in the database. `n  Check barcode and re-scan.`n  Or, coordinate the item with the front office.`n"
		    }
        }
    })

    $cf.ShowDialog()
})


$B_reportIssue.Add_Click({
    notepad.exe $dailyCorrection
})

### ADD THE QUIT BUTTON FUNCTION
$BQ.Add_Click({
    $main_form.Close()
    stop-process -Id $PID
})


### IN-HOUSE FUNCTIONS
function childFormGen(){
    
    $cf = New-Object System.Windows.Forms.Form
    $cf.Width = 750
    $cf.Height = 500
    $cf.AutoSize = $true
    $cf.Font = [System.Drawing.Font]::new("Calibri", 16, [System.Drawing.FontStyle]::Bold)
    $cf.BackColor = "Gray"
    return $cf
}

function barCodeBoxGen(){
    ### ADD A TEXT BOX FOR BARCODE INPUT FOR OPTIONS 1 & 2 ONLY
    $TEXTBOX = New-Object System.Windows.Forms.TextBox
    $TEXTBOX.Location = New-Object System.Drawing.Point(240,120)
    $TEXTBOX.Size = New-Object System.Drawing.Size(200,30)
    return $TEXTBOX
}

function resultLabelGen(){
    $result_Label = New-Object System.Windows.Forms.Label
    $result_Label.Location  = New-Object System.Drawing.size(200,230)
    $result_Label.Size = New-Object System.Drawing.Size(200,30)
    $result_Label.AutoSize = $true
    return $result_Label
}

function confirmButtonGen(){
    $confirmButton = New-Object System.Windows.Forms.Button
    $confirmButton.Location = New-Object System.Drawing.Point(230,380)
    $confirmButton.Size = New-Object System.Drawing.Size(100,50)
    $confirmButton.Text = "ENTER"
    return $confirmButton
}

##  use of pointers here
#function parseLineForPerBoxQuantity($LINE){
     ##### if perbox quantity is found, return the value, else return -1   
 #    $tokensArr = $LINE -split "`t"
  #   $numOfTokens = ($LINE -split "`t").Count
   #  $returnedInt = -1
    # for ($index = $numOfTokens - 1; $index -ge 0; $index--){
     #       [bool]$result = [int]::TryParse($tokensArr[$index], [ref]$returnedInt)
      #      if ($result -eq $true){
       #         break    
        #    }
    #}
    #return $returnedInt
#}

function getUnitQuan($item){
    
     foreach($LINE in Get-Content -path $unitQuant){
        if ($LINE -match $item){
               $tokensArr = $LINE -split "`t"
               $result = $tokensArr[$tokensArr.length - 1]
               break   
        }
     }
     # result = int or "unknown"
     return $result
}

### START THE MAIN INTERFACE
$main_form.ShowDialog()


