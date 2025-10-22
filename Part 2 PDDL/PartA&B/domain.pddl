(define (domain lunar)
    (:requirements :strips :typing)

    ; -------------------------------
    ; Types
    ; -------------------------------
    (:types
        vehicle - object
        lander rover - vehicle

        location - object

        data - object
        image scan - data

        sample - object
    )

    ; -------------------------------
    ; Predicates
    ; -------------------------------
    (:predicates
        (flying ?l - lander); lander in flight
        (landed ?l - lander); lander stationary
        
        (carrying ?l - lander ?r - rover); lander is carrying certain rover
        (commands ?l - lander ?r - rover);lander commands a rover (they are connected)

        (undeployed ?r - rover); rover not ready
        (deployed ?r - rover); rover ready

        (path ?l1 - location ?l2 - location); path exists between 1 & 2
        (located ?x - object ?l - location) ; object is in this location
        
        (heldSample ?v - vehicle ?sa - sample); sample held in vehicle storage
        (storeEmpty ?v - vehicle)
        ; (storeFull ?v - vehicle); vehicle holding physical sample

        (memEmpty ?r - rover)
        ;(memFull ?r - rover); is rover holding data in memory
        (heldData ?v - vehicle ?d - data); data stored in vehicle memory

        (transmitted ?d - data); img/scan has be transmitted to a lander
        (sampleDeposited ?s - sample); sample has been deposited in a lander
    )

    ; -------------------------------
    ; Actions
    ; -------------------------------
    (:action land_lander; land lander at any location
        :parameters (?l - lander ?lo - location)
        :precondition (and
            (flying ?l)
        )
        :effect (and
            (landed ?l)
            (not (flying ?l))
            (located ?l ?lo)
        )
    )
    
    (:action deploy_rover; deploy rover from lander that was carrying it
        :parameters (?l - lander ?r - rover ?lo - location)
        :precondition (and
            (landed ?l)
            (carrying ?l ?r)
            (commands ?l ?r)
            (undeployed ?r)
            (located ?l ?lo)
        )
        :effect (and
            (not (undeployed ?r))
            (deployed ?r)
            (not (carrying ?l ?r))
            (located ?r ?lo)
        )
    )

    (:action move_rover; move rover from one location to another
        :parameters (?r - rover ?l1 - location ?l2 - location)
        :precondition (and
            (deployed ?r)
            (located ?r ?l1)
            (path ?l1 ?l2)
        )
        :effect (and
            (not (located ?r ?l1))
            (located ?r ?l2)
        )
    )

    (:action capture_image; rover takes image at location & stores data in memory
        :parameters (?r - rover ?l - location ?i - image)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?i ?l)
            (memEmpty ?r)
        )
        :effect (and
            (heldData ?r ?i)
            ;(memFull ?r)
            (not (memEmpty ?r))
            (not (located ?i ?l)); assumed data can only be collected once
        )
    )
    
    (:action scan_radar; rover takes scan at location & stores data in memory
        :parameters (?r - rover ?l - location ?s - scan)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?s ?l)
            (memEmpty ?r)
        )
        :effect (and
            (heldData ?r ?s)
            (not (memEmpty ?r))
            ;(memFull ?r)
            (not (located ?s ?l)); assumed data can only be collected once
        )
    )

    (:action transmit_data; rover transmits held data to a lander
        :parameters (?r - rover ?l - lander ?d - data)
        :precondition (and
            (deployed ?r)
            ;(memFull ?r)
            (commands ?l ?r)
            (heldData ?r ?d)
        )
        :effect (and
            (not (heldData ?r ?d))
            (memEmpty ?r)
            ;(not (memFull ?r))
            (heldData ?l ?d)
            
            (transmitted ?d)
        )
    )

    (:action collect_sample; rover collects sample from location
        :parameters (?r - rover ?l - location ?sa - sample)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?sa ?l)
            (storeEmpty ?r)
        )
        :effect (and
            (heldSample ?r ?sa)
            ; (storeFull ?r)
            (not (storeEmpty ?r))
            (not (located ?sa ?l)); assumed sample can only be collected once
        )
    )    

    (:action deposit_sample; put sample from rover into lander
        :parameters (?r - rover ?l - lander ?lo - location ?sa - sample)
        :precondition (and
            (deployed ?r)
            (landed ?l)
            (located ?r ?lo)
            (located ?l ?lo)
            (commands ?l ?r)
            ; (storeFull ?r)
            (heldSample ?r ?sa)
            (storeEmpty ?l)
        )
        :effect (and
            (not (heldSample ?r ?sa))
            (storeEmpty ?r)
            ; (not (storeFull ?r))

            (heldSample ?l ?sa)
            ; (storeFull ?l)
            (not (storeEmpty ?l))
            
            (sampleDeposited ?sa)
        )
    )

    ; (:action collect_sample
    ;     :parameters (?r - rover ?l - location ?sa - sample)
    ;     :precondition (and
    ;         (deployed ?r)
    ;         (located ?r ?l)
    ;         (storeEmpty ?r)
            
    ;         (located ?sa ?l)
    ;     )
    ;     :effect (and
    ;         (not (storeEmpty ?r))
    ;         (storeFull ?r)

    ;         (heldSample ?r ?sa)

    ;         (not (located ?sa ?l))
    ;     )
    ; )
    
    ; (:action deposit_sample
    ;     :parameters (?r - rover ?l - lander ?lo - location ?sa - sample)
    ;     :precondition (and
    ;         (deployed ?r)
    ;         (located ?r ?lo)
    ;         (storeFull ?r)

    ;         (landed ?l)
    ;         (located ?l ?lo)
    ;         (storeEmpty ?l)

    ;         (commands ?l ?r)
    ;     )
    ;     :effect (and
    ;         (not (storeFull ?r))
    ;         (storeEmpty ?r)
    ;         (not (heldSample ?r ?sa))

    ;         (not (storeEmpty ?l))
    ;         (storeFull ?l)
    ;         (heldSample ?l ?sa)

    ;         (sampleDeposited ?sa)
    ;     )
    ; )
)