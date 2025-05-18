package edu.hm.cs.kreisel_backend.config;

import edu.hm.cs.kreisel_backend.model.*;
import edu.hm.cs.kreisel_backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.util.Arrays;

@Configuration
public class DataInitializer {

    @Autowired
    private CategoryRepository categoryRepo;

    @Autowired
    private LocationRepository locationRepo;

    @Autowired
    private EquipmentRepository equipmentRepo;

    @Autowired
    private UserRepository userRepo;

    @Autowired
    private RentalRepository rentalRepo;

    @Autowired
    private RatingRepository ratingRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initDatabase() {
        return args -> {
            // Only initialize if the database is empty
            if (userRepo.count() > 0) {
                return;
            }

            // Create categories if they don't exist yet
            if (categoryRepo.count() == 0) {
                Category ballsCategory = new Category();
                ballsCategory.setName("Bälle");

                Category bikesCategory = new Category();
                bikesCategory.setName("Fahrräder");

                Category waterCategory = new Category();
                waterCategory.setName("Wassersport");

                Category winterCategory = new Category();
                winterCategory.setName("Wintersport");

                categoryRepo.saveAll(Arrays.asList(ballsCategory, bikesCategory, waterCategory, winterCategory));
            }

            // Create locations if they don't exist yet
            if (locationRepo.count() == 0) {
                Location pasingLocation = new Location();
                pasingLocation.setName("Pasing");

                Location lothstrasseLocation = new Location();
                lothstrasseLocation.setName("Lothstraße");

                locationRepo.saveAll(Arrays.asList(pasingLocation, lothstrasseLocation));
            }

            // Create users
            User admin = new User();
            admin.setEmail("admin@hm.edu");
            admin.setPassword(passwordEncoder.encode("password"));
            admin.setRole(User.Role.ADMIN);

            User user1 = new User();
            user1.setEmail("student1@hm.edu");
            user1.setPassword(passwordEncoder.encode("password"));
            user1.setRole(User.Role.USER);

            User user2 = new User();
            user2.setEmail("student2@hm.edu");
            user2.setPassword(passwordEncoder.encode("password"));
            user2.setRole(User.Role.USER);

            userRepo.saveAll(Arrays.asList(admin, user1, user2));

            // Create equipment
            Category ballsCategory = categoryRepo.findAll().stream()
                    .filter(c -> c.getName().equals("Bälle"))
                    .findFirst()
                    .orElseThrow();

            Category bikesCategory = categoryRepo.findAll().stream()
                    .filter(c -> c.getName().equals("Fahrräder"))
                    .findFirst()
                    .orElseThrow();

            Location pasingLocation = locationRepo.findAll().stream()
                    .filter(l -> l.getName().equals("Pasing"))
                    .findFirst()
                    .orElseThrow();

            Location lothstrasseLocation = locationRepo.findAll().stream()
                    .filter(l -> l.getName().equals("Lothstraße"))
                    .findFirst()
                    .orElseThrow();

            Equipment football = new Equipment();
            football.setName("Fußball");
            football.setType("Adidas");
            football.setDescription("Offizieller Bundesliga-Ball");
            football.setAvailable(true);
            football.setCategory(ballsCategory);
            football.setLocation(pasingLocation);

            Equipment basketball = new Equipment();
            basketball.setName("Basketball");
            basketball.setType("Spalding");
            basketball.setDescription("Profi-Basketball");
            basketball.setAvailable(true);
            basketball.setCategory(ballsCategory);
            basketball.setLocation(lothstrasseLocation);

            Equipment volleyball = new Equipment();
            volleyball.setName("Volleyball");
            volleyball.setType("Mikasa");
            volleyball.setDescription("Beach-Volleyball");
            volleyball.setAvailable(true);
            volleyball.setCategory(ballsCategory);
            volleyball.setLocation(pasingLocation);

            Equipment cityBike = new Equipment();
            cityBike.setName("City Bike");
            cityBike.setType("Giant");
            cityBike.setDescription("Stadtfahrrad mit 7 Gängen");
            cityBike.setAvailable(true);
            cityBike.setCategory(bikesCategory);
            cityBike.setLocation(lothstrasseLocation);

            Equipment mountainBike = new Equipment();
            mountainBike.setName("Mountainbike");
            mountainBike.setType("Trek");
            mountainBike.setDescription("Geländefahrrad mit 21 Gängen");
            mountainBike.setAvailable(false);  // Already rented
            mountainBike.setCategory(bikesCategory);
            mountainBike.setLocation(pasingLocation);

            equipmentRepo.saveAll(Arrays.asList(football, basketball, volleyball, cityBike, mountainBike));

            // Create some rentals
            Rental rental1 = new Rental();
            rental1.setUser(user1);
            rental1.setEquipment(mountainBike);
            rental1.setStartDate(LocalDate.now().minusDays(5));
            rental1.setEndDate(LocalDate.now().plusDays(2));
            rental1.setReturned(false);

            Rental rental2 = new Rental();
            rental2.setUser(user2);
            rental2.setEquipment(football);
            rental2.setStartDate(LocalDate.now().minusDays(10));
            rental2.setEndDate(LocalDate.now().minusDays(8));
            rental2.setReturned(true);

            // Need to temporarily set football to unavailable
            football.setAvailable(false);
            equipmentRepo.save(football);

            rentalRepo.saveAll(Arrays.asList(rental1, rental2));

            // Set football back to available since it was returned
            football.setAvailable(true);
            equipmentRepo.save(football);

            // Create some ratings
            Rating rating1 = new Rating();
            rating1.setUser(user1);
            rating1.setEquipment(football);
            rating1.setRating(5);
            rating1.setComment("Super Ball, sehr gut zu spielen!");

            Rating rating2 = new Rating();
            rating2.setUser(user2);
            rating2.setEquipment(football);
            rating2.setRating(4);
            rating2.setComment("Guter Ball, aber könnte mehr Luft haben.");

            Rating rating3 = new Rating();
            rating3.setUser(user2);
            rating3.setEquipment(cityBike);
            rating3.setRating(3);
            rating3.setComment("Funktioniert gut, aber die Gangschaltung ist etwas schwergängig.");

            ratingRepo.saveAll(Arrays.asList(rating1, rating2, rating3));

            System.out.println("Database initialized with sample data!");
        };
    }
}