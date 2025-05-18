package edu.hm.cs.kreisel_backend.dto;

import edu.hm.cs.kreisel_backend.model.Rental;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class RentalResponse {
    private final Long id;
    private final Long equipmentId;
    private final String equipmentName;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final boolean returned;

    public RentalResponse(Rental rental) {
        this.id = rental.getId();
        this.equipmentId = rental.getEquipment() != null ? rental.getEquipment().getId() : null;
        this.equipmentName = rental.getEquipment() != null ? rental.getEquipment().getName() : "Unbekannt";
        this.startDate = rental.getStartDate();
        this.endDate = rental.getEndDate();
        this.returned = rental.isReturned();
    }
}
