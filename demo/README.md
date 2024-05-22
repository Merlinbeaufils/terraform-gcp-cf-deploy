
# Further development instructions
## Setup
Follow the instructions in the README.md file [here](../terraform/README.md)

## Repo structure

```
project_root/
    app/    
    cloud_functions/
    terraform/
    demo/
    .env.example
    README.md           
    requirements.txt
```
### Mandatory:
- All repositories should have a README.md file detailing it´s purpose and how to use it.
- All repositories should have a requirements.txt file with the necessary dependencies to run the code.
- All repositories should have a .env.example file detailing the necessary environment variables to run the code. 
**Do not fill the values of sensitive variables in the .env.example file!!!!!!!!**
**DO NOT UPLOAD .env FILE!!!!!**
### Optional:
- app/
  - the app module ("module" because it should have a __init__.py file inside so it can be imported)
  - should contain all functionality of your application
  
- cloud_functions/ : 
```
cloud_functions/
    function1/
        main.py
        requirements.txt
    function2/
        main.py
        requirements.txt
    zip_cloud_functions.py
```

  - This folder shoul be structured as seen above. One folder per function. 
  - main.py inside each function folder with an "invoke" function that is called by the cloud function.
  - requirement.txt inside each folder detailing its dependencies
  - zip_cloud_functions.py is a script with 2 functionalities. 
    - It copies and pastes the app/ module into the function folder so that it can be imported in main.py
    - it zips the folder so that it can uploaded to a storage bucket and deployed from there



## Onion Architecture

Onion architecture is a way to organize your code in a way that each functionality is
modular and can be edited without affecting the larger functioning of the application.

You want to first separate your code by entities. 
For example, in this case, we want to build a searching app. We should define the objects being searched and the actual searching separately.

we have a target entity which needs certain functionalities and the core search functionality which needs other functionalities.
We want to be able to change how the target class works without affecting the search functionality and vice versa. We will also have a "shared" entity folder 
for supporting entities and functionalities.

This gives us the following starting structure:
```
app/
    __init__.py
    target/
        __init__.py
        ...
    search/
        __init__.py
        ...
    shared/
        __init__.py
        ...
    
```

For each entity now we will split it further. Each folder will have 3 layers just like an onion:
![image info](assets/onion-layers.png)

We will have domain, application and infrastructure layers for each entity. Ideally each folder should only be able to import from inside a lower layer. 

Let's start with target:
```

target/
    __init__.py
    domain/
        __init__.py
        target.py
    application/
        __init__.py
        set_target.py
        remove_target.py
    infrastructure/
        __init__.py
        firestore_target_repository.py
```
In domain, we will define the abstract classes that we will need throughout our application. We will define their attributes and methods (but *we will not implement them!*).

In target, we will define a target class and a target collection (repository) class. 
We define that the target needs to be able to turn itself into a serializable dict (json-able basically)
and also that it needs to turn itself into a string for the search application.
```python
from abc import ABCMeta, abstractmethod
from typing import Dict
from pydantic import BaseModel

JSON = Dict[str, 'JSON']

class BaseTarget(BaseModel):
  """
  Abstract class for the target entity.

  Defines to_dict and form_search_term methods.
  """
  __metaclass__ = ABCMeta
  
  @abstractmethod
  def to_dict(self) -> JSON:
      """ Returns a serializable dict representation of the entity
      :return: json serializable dict
      """
      raise NotImplementedError
  
  @abstractmethod
  def form_search_term(self) -> str:
      """ Returns a string representation of the entity to be used in the search engine
      :return: string representation
      """
      raise NotImplementedError
```
Similarly the target collection class:

```python
from abc import ABCMeta, abstractmethod
from typing import Optional

from app.target.domain.target import BaseTarget


class TargetRepository:
    """
    Abstract class for collections of target entities.

    Defines set, delete and search methods.
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def set(self, target: BaseTarget) -> None:
        """ set a target entity in the collection """
        raise NotImplementedError

    @abstractmethod
    def delete(self, target_key: str) -> None:
        """ delete a target entity from the collection """
        raise NotImplementedError

    @abstractmethod
    def search(self, target_key: str) -> Optional[BaseTarget]:
        """ search a target entity in the collection by id """
        raise NotImplementedError
```
Now let's look quickly at the search: 
```python
from abc import abstractmethod, ABCMeta
from typing import Tuple, List

from numpy import ndarray

class SearchRepository:
    """
    Search repository for searching nearest targets.

    Repository contains the id and embedding of the targets.
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def set(self, target_id: str, embedding: ndarray) -> None:
        """
        Sets a target embedding in the search collection.

        :param target_id: id of the target to set
        :param embedding: vector embedding of the target
        :return None
        """
        raise NotImplementedError

    @abstractmethod
    def search(self, query: ndarray, n_results: int) -> List[Tuple[str, float]]:
        """
        Searches the nearest targets to the query.

        :param query: query vector to search with
        :param n_results: number of results to return
        :return: list of target ids and their scores
        """
        raise NotImplementedError

    @abstractmethod
    def delete(self, target_id: str) -> None:
        """
        Deletes a target from the search collection.

        :param target_id: id of the target to delete
        :return None
        """
        raise NotImplementedError
```
Important things to note are:
  - Every class is an abstract class. This means that it is just a definition of what the class should be able to do. It does not actually implement the functionality.
  - We are very detailed in defining the inputs as well as their types and the outputs and their types.

The point of this domain layer is that, with these definitions, we can already define the "use_cases" or "application" layer without 


## Application Functionality

### set_target function
- Input: target (json/dict)
- saves to firestore
- embeds it using openai 
- saves the embedding in redis
- use a POST request

### remove_target function
- Input: target id (str)
- Removes target from firestore
- Removes target from redis
- use a GET request

### search_target function
- Input: query (str)
- Runs KNN in redis and return the top results
- use a GET request




# Docker
```bash
docker build -t local-docker-image local.Dockerfile .
docker run --name local-docker-container -p 8080:8080 local-docker-image
```
## Usage
To customize this repo, simply check for TODOs in the code and follow the associated instructions.
- Customize the Target class with the necessary attributes
- set LOCAL_DEVELOPMENT in app.shared.domain.local_development_bool to True or False




## Clase rapida codigo clean

- What is an ABC class and how is it used
  - An abc class defines a class along with all the necessary attributes and methods that it will need.
  - The idea is to "define" the functionalities of an object without actually implementing them.
  - Further outside in the code, we will create a subclass that inherits from the ABC class and implements the methods and attributes that were defined in the ABC class.
    - For example if I defined a collection of targets TargetRepository that can delete or add researchers, I would define a subclass FirestoreTargetRepository(ResearcherRepository) that must now implement the adding or deleting functions specific to firestore. 

- Why does this matter?
    - Sometimes when writing code, I don't want my code to depend on specific frameworks like google or azure.
    - I want to implement use cases (ie. add a target) without actually caring if this is done locally, in firestore or in azure cloud.
    - To respond to this, "Clean" architecture separates code in three layers domain, application and infrastructure.
    - These are like layers of an onion, where the order from insidemost to outsidemost layers is domain, application and infrastructure.
      - The domain class will define all important classes and functionalities needed in the code without actually implementing them.
      - The application layer will build from these definitions and create useful methods that do not care how the sub functions are implemented.
      - Finally the infrastructure layer will actually implement the sub functionalities specific to frameworks being used like openai, firestore, azure, etc.
      - example:
        - Domain layer: 
          - I define a Target class representing what the search will target. ie a researcher or a socio fundador...
          - I define a TargetRepository class that is just a fancy list of targets. 
          - For both these classes, I define their methods, like add_researcher or delete_socio_fundador. I want to be extremely specific about what these functions take in, what they are supposed to do and what they will return but I DONT IMPLEMENT IT. 
          - In fact, I put a raise NotImplementedError in the body of these functions to make sure they will be implemented outside.
        - Application layer:
          - I define the use cases. In our cloud functions we will have add_target and delete_target.
          - I implement these using the TargetRepository and target class definitions. 
          - Note that nothing is functional still because the subfunctions are still not implemented.
        - Infrastructure layer:
          - I make a FirestoreTargetRepository class that actually implements the functionalities of the TargetRepository class.
          - I also make a LocalTargetRepository class that implements it in a local folder if we want to test without firestore.
        - Dependency injection:
          - **This is the key to understanding clean architecture**
          - This is what bundles everything together and creates a working application.
          - In the depency injection file I create a DependencyInjectionContainer which will construct the whole target entity with the specificics of using the Firestore repo instead of local
      

  
