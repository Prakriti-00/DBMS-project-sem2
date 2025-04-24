document.getElementById('petForm').addEventListener('submit', function(event) {
  event.preventDefault(); // Prevent the default form submission behavior

  // Get the form data
  const petName = document.getElementById('petName').value;
  const petSpecies = document.getElementById('petSpecies').value;
  const petBreed = document.getElementById('petBreed').value;
  const petAge = document.getElementById('petAge').value;

  // Get the user_id (this could come from a hidden field, session, or another dynamic method)
  const userId = document.getElementById('userId').value; // You may need to set this value dynamically, depending on your authentication method

  // Check if user_id is available
  if (!userId) {
    alert('User ID is required');
    return;
  }

  // Send a POST request to add a new pet
  fetch('http://localhost:3000/pets', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      name: petName,
      species: petSpecies,
      breed: petBreed,
      age: petAge,
      user_id: userId // Include user_id in the request body
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.message) {
      alert(data.message); // Show success message
      loadPets(); // Refresh the pet list
    } else {
      alert('Error: ' + data.error); // Show error message
    }
  })
  .catch(error => {
    console.error('Error:', error);
    alert('There was an error adding the pet');
  });
});

// Function to load the pets from the server
function loadPets() {
  fetch('http://localhost:3000/pets')
    .then(response => response.json())
    .then(pets => {
      const petList = document.getElementById('petList');
      petList.innerHTML = ''; // Clear the current list
      pets.forEach(pet => {
        const petItem = document.createElement('li');
        petItem.textContent = `${pet.name} - ${pet.species} - ${pet.breed} - Age: ${pet.age}`;
        petList.appendChild(petItem);
      });
    })
    .catch(error => {
      console.error('Error fetching pets:', error);
    });
}

// Load pets on page load
window.onload = loadPets;