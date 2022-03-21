
let btnSearch = document.getElementById("btnSearch")
let drivingRecordsList = document.getElementById("driving-records")
let drivingLicenseNumberTextBox = document.getElementById("drivingLicenseNumberTextBox")


btnSearch.addEventListener('click',function(){

  drivingRecordsList.innerHTML = ''

   let drivingLicenseNumber = drivingLicenseNumberTextBox.value
   let url = "http://localhost:8080/driving-records/" + drivingLicenseNumber

   fetch(url)
   .then(r => r.json())
   .then(drivingRecords => {

      drivingRecords.map(record => {

          let item = document.createElement("li")
          let divItem = document.createElement("div")

          let noOfVoilationsLabel = document.createElement("label")
          let voilationTypeLabel = document.createElement("label")
          let isDrivingLicenseSuspendedLabel = document.createElement("label")

          noOfVoilationsLabel.innerHTML = "No Of Voilations: " + record.noOfVoilations.toString()
          voilationTypeLabel.innerHTML = "Voilation Type: " + record.voilationType
          isDrivingLicenseSuspendedLabel.innerHTML = "Is Driving License Suspended: " + record.isDrivingLicenseSuspended.toString()


          divItem.appendChild(noOfVoilationsLabel)
          divItem.appendChild(voilationTypeLabel)
          divItem.appendChild(isDrivingLicenseSuspendedLabel)

          item.appendChild(divItem)

          drivingRecordsList.appendChild(item)

      })

   })

})
