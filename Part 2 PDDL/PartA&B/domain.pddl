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
        (flying ?l - lander)
        (landed ?l - lander); lander stationary
        
        (carrying ?l - lander ?r - rover); lander is carrying certain rover
        (commands ?l - lander ?r - rover);lander commands a rover (they are connected)

        (undeployed ?r - rover)
        (deployed ?r - rover); rover ready
        (path ?l1 - location ?l2 - location); path exists between 1 & 2
        (located ?x - object ?l - location) ; object is in this location
        
        (heldSample ?v - vehicle ?s - sample); sample held in vehicle storage
        (storeEmpty ?v - vehicle)
        (storeFull ?v - vehicle); vehicle holding physical sample

        (memEmpty ?r - rover)
        ;(memFull ?r - rover); is rover holding data in memory
        (heldData ?v - vehicle ?d - data); data stored in vehicle memory
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
            (not (carrying ?l ?r))
            (deployed ?r)
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
            (located ?r ?l)
            (located ?i ?l)
            (deployed ?r)
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
            (located ?r ?l)
            (located ?s ?l)
            (deployed ?r)
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
            ;(memFull ?r)
            (commands ?l ?r)
            (heldData ?r ?d)
            (deployed ?r)
        )
        :effect (and
            (not (heldData ?r ?d))
            (memEmpty ?r)
            ;(not (memFull ?r))
            (heldData ?l ?d)
        )
    )

    (:action collect_sample; rover collects sample from location
        :parameters (?r - rover ?l - location ?s - sample)
        :precondition (and
            (located ?r ?l)
            (located ?s ?l)
            (storeEmpty ?r)
        )
        :effect (and
            (heldSample ?r ?s)
            ;(storeFull ?r)
            (not (storeEmpty ?r))
            (not (located ?s ?l)); assumed sample can only be collected once
        )
    )
    

    (:action deposit_sample; put sample from rover into lander
        :parameters (?r - rover ?l - lander ?lo - location ?s - sample)
        :precondition (and
            (located ?r ?lo)
            (located ?l ?lo)
            ;(storeFull ?r)
            (heldSample ?r ?s)
            (storeEmpty ?l)
        )
        :effect (and
            (not (heldSample ?r ?s))
            (storeEmpty ?r)
            ;(not (storeFull ?r))
            (heldSample ?l ?s)
            (not (storeEmpty ?l))
            (storeFull ?l)
        )
    )
)