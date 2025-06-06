package edu.hm.cs.kreisel_backend.controller;

import edu.hm.cs.kreisel_backend.model.Item;
import edu.hm.cs.kreisel_backend.model.Item.*;
import edu.hm.cs.kreisel_backend.model.User;
import edu.hm.cs.kreisel_backend.security.SecurityUtils;
import edu.hm.cs.kreisel_backend.service.ItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;
    private final SecurityUtils securityUtils;

    //nur der User soll diese Methode haben um nach seinen Wünschen zu filtern
    // Haupt-GET-Endpunkt mit allen Filtern
    @GetMapping
    public ResponseEntity<List<Item>> getFilteredItems(
            @RequestParam Location location,                    // Pflicht: Standort
            @RequestParam(required = false) Boolean available,   // Optional: Verfügbarkeit
            @RequestParam(required = false) String searchQuery,  // Optional: Textsuche
            @RequestParam(required = false) Gender gender,       // Optional: Gender
            @RequestParam(required = false) Category category,   // Optional: Kategorie
            @RequestParam(required = false) Subcategory subcategory, // Optional: Unterkategorie
            @RequestParam(required = false) String size          // Optional: Größe
    ) {
        return ResponseEntity.ok(itemService.filterItems(
                location,
                available,
                searchQuery,
                gender,
                category,
                subcategory,
                size
        ));
    }

    //hier was sinnvolles machen
    @GetMapping("/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        return ResponseEntity.ok(itemService.getItemById(id));
    }
//nur der admin soll das machen dürfen
    @PostMapping
    public ResponseEntity<Item> createItem(@RequestBody Item item) {
        User currentUser = securityUtils.getCurrentUser();
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        if (!currentUser.getRole().equals(User.Role.ADMIN)) {
            return ResponseEntity.status(403).build();
        }

        return ResponseEntity.ok(itemService.createItem(item));
    }
//nur der admin soll das machen dürfen
    @PutMapping("/{id}")
    public ResponseEntity<Item> updateItem(@PathVariable Long id, @RequestBody Item item) {
        User currentUser = securityUtils.getCurrentUser();
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        if (!currentUser.getRole().equals(User.Role.ADMIN)) {
            return ResponseEntity.status(403).build();
        }

        return ResponseEntity.ok(itemService.updateItem(id, item));
    }
// nur der Admin soll das machen dürfen
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        User currentUser = securityUtils.getCurrentUser();
        if (currentUser == null) {
            return ResponseEntity.status(401).build();
        }

        if (!currentUser.getRole().equals(User.Role.ADMIN)) {
            return ResponseEntity.status(403).build();
        }

        itemService.deleteItem(id);
        return ResponseEntity.ok().build();
    }
}
