// Pet data storage
let pets = [];
let activities = [];
let healthRecords = [];
let vets = ["Dr. Smith", "Dr. Johnson", "Dr. Williams"];

// DOM elements
const petForm = document.getElementById('petForm');
const activityForm = document.getElementById('activityForm');
const healthForm = document.getElementById('healthForm');
const petList = document.getElementById('petList');
const activityLogs = document.getElementById('activityLogs');
const healthRecordsContainer = document.getElementById('healthRecords');
const activityPetSelect = document.getElementById('activityPet');
const healthPetSelect = document.getElementById('healthPet');

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
    // Load sample data
    loadSampleData();
    
    // Form event listeners
    petForm.addEventListener('submit', addPet);
    activityForm.addEventListener('submit', logActivity);
    healthForm.addEventListener('submit', addHealthRecord);
    
    // Render initial data
    renderPets();
    updatePetSelects();
    
    // Start hunger timer (increases hunger every minute)
    setInterval(increaseHunger, 60000);
});

// Hunger system
function increaseHunger() {
    pets.forEach(pet => {
        // Increase hunger (capped at 100)
        pet.hunger = Math.min(100, (pet.hunger || 50) + 5);
        
        // Happiness is inversely proportional to hunger (100 - hunger)
        pet.happiness = Math.max(0, 100 - pet.hunger);
    });
    renderPets();
}

// Tab functionality
function openTab(tabName) {
    const tabContents = document.getElementsByClassName('tab-content');
    const tabButtons = document.getElementsByClassName('tab-btn');
    
    for (let i = 0; i < tabContents.length; i++) {
        tabContents[i].classList.remove('active');
        tabButtons[i].classList.remove('active');
    }
    
    document.getElementById(tabName).classList.add('active');
    event.currentTarget.classList.add('active');
    
    if (tabName === 'activities') {
        renderActivities();
    } else if (tabName === 'health') {
        renderHealthRecords();
    }
}

// Pet functions
async function addPet(e) {
    e.preventDefault();
    console.log("Form submitted!");

    const name = document.getElementById('petName').value;
    console.log("Submitting pet:", name);
    const species = document.getElementById('petSpecies').value;
    const breed = document.getElementById('petBreed').value;
    const age = document.getElementById('petAge').value;
    
    if (name && species) {
        try {
            const submitBtn = e.target.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.textContent = 'Adding...';
            
            const response = await fetch('http://localhost:3000/pets', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    name,
                    species,
                    breed: breed || 'Unknown',
                    age: age || 0,
                    user_id: 1 // You'll need to implement user authentication
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to add pet');
            }
            
            const result = await response.json();
            
            // Add the new pet to local state
            const newPet = {
                id: result.pet_id,
                name,
                species,
                breed: breed || 'Unknown',
                age: age || 0,
                happiness: 70,  // Default values
                hunger: 30,
                health: 100,
                lastFed: new Date(),
                lastActivity: new Date()
            };
            
            pets.push(newPet);
            renderPets();
            updatePetSelects();
            petForm.reset();
            
        } catch (error) {
            console.error('Error adding pet:', error);
            alert(error.message || 'Failed to add pet. Please try again.');
        } finally {
            const submitBtn = e.target.querySelector('button[type="submit"]');
            submitBtn.disabled = false;
            submitBtn.textContent = 'Add Pet';
        }
    } else {
        alert('Please fill in at least name and species');
    }
}

function renderPets() {
    petList.innerHTML = '';
    
    pets.forEach(pet => {
        // Determine happiness level class
        let happinessClass = 'happiness-medium';
        if (pet.happiness < 30) {
            happinessClass = 'happiness-low';
        } else if (pet.happiness > 70) {
            happinessClass = 'happiness-high';
        }
        
        // Determine hunger level class
        let hungerClass = 'hunger-medium';
        if (pet.hunger < 30) {
            hungerClass = 'hunger-low';
        } else if (pet.hunger > 70) {
            hungerClass = 'hunger-high';
        }
        
        const petCard = document.createElement('div');
        petCard.className = 'pet-card';
        petCard.innerHTML = `
            <h3>${pet.name}</h3>
            <p>Species: ${pet.species}</p>
            <p>Breed: ${pet.breed}</p>
            <p>Age: ${pet.age} years</p>
            
            <p>Happiness: ${pet.happiness}%</p>
            <div class="meter">
                <div class="meter-level ${happinessClass}" style="width: ${pet.happiness}%"></div>
            </div>
            
            <p>Hunger: ${pet.hunger}%</p>
            <div class="meter">
                <div class="meter-level ${hungerClass}" style="width: ${pet.hunger}%"></div>
            </div>
            
            <p>Health: ${pet.health}%</p>
            <button onclick="playWithPet(${pet.id})">Play</button>
            <button onclick="feedPet(${pet.id})">Feed</button>
            <button onclick="removePet(${pet.id})" class="danger">Remove</button>
        `;
        petList.appendChild(petCard);
    });
}

function playWithPet(petId) {
    const pet = pets.find(p => p.id === petId);
    if (pet) {
        // Playing increases hunger
        pet.hunger = Math.min(100, pet.hunger + 20);
        // Happiness is inversely tied to hunger
        pet.happiness = Math.max(0, 100 - pet.hunger);
        pet.lastActivity = new Date();
        renderPets();
        
        // Log activity
        activities.push({
            petId,
            petName: pet.name,
            activity: 'Play',
            timestamp: new Date()
        });
    }
}

function feedPet(petId) {
    const pet = pets.find(p => p.id === petId);
    if (pet) {
        // Feeding decreases hunger
        pet.hunger = Math.max(0, pet.hunger - 30);
        // Happiness improves as hunger decreases
        pet.happiness = Math.max(0, 100 - pet.hunger);
        pet.lastFed = new Date();
        renderPets();
        
        // Log activity
        activities.push({
            petId,
            petName: pet.name,
            activity: 'Feed',
            timestamp: new Date()
        });
    }
}

async function removePet(petId) {
    if (confirm('Are you sure you want to remove this pet?')) {
        try {
            // Send DELETE request to backend
            const response = await fetch(`http://localhost:3000/pets/${petId}`, {
                method: 'DELETE'
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Failed to delete pet');
            }

            // Remove pet from local state
            pets = pets.filter(p => p.id !== petId);
            renderPets();
            updatePetSelects();
        } catch (error) {
            console.error('Error deleting pet:', error);
            alert(error.message || 'Failed to delete pet. Please try again.');
        }
    }
}


// Activity functions
function logActivity(e) {
    e.preventDefault();
    
    const petId = parseInt(activityPetSelect.value);
    const activity = document.getElementById('activityType').value;
    
    if (petId && activity) {
        const pet = pets.find(p => p.id === petId);
        
        if (pet) {
            activities.push({
                petId,
                petName: pet.name,
                activity,
                timestamp: new Date()
            });
            
            // Update pet stats based on activity
            switch(activity) {
                case 'Walk':
                    pet.hunger = Math.min(100, pet.hunger + 20);
                    pet.health = Math.min(100, pet.health + 10);
                    break;
                case 'Play':
                    pet.hunger = Math.min(100, pet.hunger + 15);
                    break;
                case 'Feed':
                    pet.hunger = Math.max(0, pet.hunger - 30);
                    pet.health = Math.min(100, pet.health + 5);
                    break;
                case 'Training':
                    pet.hunger = Math.min(100, pet.hunger + 10);
                    break;
            }
            
            // Update happiness based on new hunger level
            pet.happiness = Math.max(0, 100 - pet.hunger);
            
            renderActivities();
            renderPets();
            activityForm.reset();
        }
    }
}

function renderActivities() {
    activityLogs.innerHTML = '';
    
    if (activities.length === 0) {
        activityLogs.innerHTML = '<p>No activities logged yet.</p>';
        return;
    }
    
    activities.forEach(activity => {
        const activityLog = document.createElement('div');
        activityLog.className = 'activity-log';
        activityLog.innerHTML = `
            <h3>${activity.petName}</h3>
            <p>Activity: ${activity.activity}</p>
            <p>Date: ${new Date(activity.timestamp).toLocaleString()}</p>
        `;
        activityLogs.appendChild(activityLog);
    });
}

// Health record functions
function addHealthRecord(e) {
    e.preventDefault();
    
    const petId = parseInt(healthPetSelect.value);
    const vet = document.getElementById('healthVet').value;
    const date = document.getElementById('checkupDate').value;
    const diagnosis = document.getElementById('diagnosis').value;
    const treatment = document.getElementById('treatment').value;
    
    if (petId && vet && date && diagnosis && treatment) {
        const pet = pets.find(p => p.id === petId);
        
        if (pet) {
            healthRecords.push({
                petId,
                petName: pet.name,
                vet,
                date,
                diagnosis,
                treatment,
                timestamp: new Date()
            });
            
            // Update pet health
            pet.health = Math.min(100, pet.health + 20);
            
            renderHealthRecords();
            renderPets();
            healthForm.reset();
        }
    }
}

function renderHealthRecords() {
    healthRecordsContainer.innerHTML = '';
    
    if (healthRecords.length === 0) {
        healthRecordsContainer.innerHTML = '<p>No health records yet.</p>';
        return;
    }
    
    healthRecords.forEach(record => {
        const healthRecord = document.createElement('div');
        healthRecord.className = 'health-record';
        healthRecord.innerHTML = `
            <h3>${record.petName}</h3>
            <p>Veterinarian: ${record.vet}</p>
            <p>Date: ${new Date(record.date).toLocaleDateString()}</p>
            <p>Diagnosis: ${record.diagnosis}</p>
            <p>Treatment: ${record.treatment}</p>
            <p>Recorded: ${new Date(record.timestamp).toLocaleString()}</p>
        `;
        healthRecordsContainer.appendChild(healthRecord);
    });
}

// Utility functions
function updatePetSelects() {
    activityPetSelect.innerHTML = '<option value="">Select Pet</option>';
    healthPetSelect.innerHTML = '<option value="">Select Pet</option>';
    
    pets.forEach(pet => {
        const option = document.createElement('option');
        option.value = pet.id;
        option.textContent = pet.name;
        
        activityPetSelect.appendChild(option.cloneNode(true));
        healthPetSelect.appendChild(option);
    });
}

function loadSampleData() {
    // Sample pets
    pets = [
        {
            id: 1,
            name: "Buddy",
            species: "Dog",
            breed: "Golden Retriever",
            age: 3,
            happiness: 70,
            hunger: 30,
            health: 90,
            lastFed: new Date(),
            lastActivity: new Date()
        },
        {
            id: 2,
            name: "Whiskers",
            species: "Cat",
            breed: "Siamese",
            age: 2,
            happiness: 70,
            hunger: 30,
            health: 85,
            lastFed: new Date(),
            lastActivity: new Date()
        }
    ];
    
    // Sample activities
    activities = [
        {
            petId: 1,
            petName: "Buddy",
            activity: "Walk",
            timestamp: new Date(Date.now() - 86400000)
        },
        {
            petId: 2,
            petName: "Whiskers",
            activity: "Play",
            timestamp: new Date(Date.now() - 3600000)
        }
    ];
    
    // Sample health records
    healthRecords = [
        {
            petId: 1,
            petName: "Buddy",
            vet: "Dr. Smith",
            date: "2023-05-15",
            diagnosis: "Annual checkup",
            treatment: "Vaccination and general health check",
            timestamp: new Date(Date.now() - 2592000000)
        }
    ];
}