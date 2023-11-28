@terminplanung
@mandatory
@Communication-Read
Feature: Lesen der Ressource Communication (@Communication-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Titus UI eingegeben worden sein.

      Legen Sie antwortend auf eine vorherige Nachricht folgende Nachricht in Ihrem System an:
      Status: abgeschlossen
      Patient: Der Patient aus Testfall Patient-Read
      Sendedatum: Beliebig
      Empfänger: Der Arzt aus Testfall Practitioner-Read (Bitte ID in die terminplanung.yaml eingeben)
      Sender: Der Patient aus Testfall Patient-Read (Bitte ID im Titus GUI eingeben)
      Inhalt schriftlich: Dies ist eine Testnachricht!
      Zusätzlicher Anhang: text/plain, https://test, beliebig (Typ, Url, Erstellungsdatum)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Communication" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer Nachricht anhand der ID
    Then Get FHIR resource at "http://fhirserver/Communication/${data.communication-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.communication-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Communication"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKNachricht"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath "inResponseTo.exists()" with error message 'Eine Referenz auf die vorherige Nachricht ist nicht vorhanden'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body evaluates the FHIRPath "sent.exists()" with error message 'Das Sendedatum ist nicht vorhanden'
    And FHIR current response body evaluates the FHIRPath "recipient.where(display.exists() and reference.replaceMatches('/_history/.+','').matches('${data.practitioner-read-id}')).exists()" with error message 'Der Empfänger entspricht nicht dem Erwartungswert oder ist nicht vollständig vorhanden'
    And FHIR current response body evaluates the FHIRPath "sender.where(reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')).exists()" with error message 'Der Sender entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payload.where(content.contains('Dies ist eine Testnachricht!')).exists()" with error message 'Der schriftliche Inhalt entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "payload.content.where(contentType = 'text/plain' and url = 'https://test' and creation.exists()).exists()" with error message 'Der zusätzliche Anhang entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "sender.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'ID des Senders entspricht nicht dem Erwartungswert'
