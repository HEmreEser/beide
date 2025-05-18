
package edu.hm.cs.kreisel_backend.dto;

import edu.hm.cs.kreisel_backend.model.Rating;
import lombok.Getter;

@Getter
public class RatingResponse {
    private final Long id;
    private final Long equipmentId;
    private final String equipmentName;
    private final int stars;
    private final String comment;
    private final String userEmail;

    public RatingResponse(Rating rating) {
        this.id = rating.getId();
        this.equipmentId = rating.getEquipment() != null ? rating.getEquipment().getId() : null;
        this.equipmentName = rating.getEquipment() != null ? rating.getEquipment().getName() : "Unbekannt";
        this.stars = rating.getRating();
        this.comment = rating.getComment();
        this.userEmail = rating.getUser() != null ? rating.getUser().getEmail() : "Unbekannt";
    }
}