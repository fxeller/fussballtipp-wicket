package de.delmak.fussballtipp.persistence;

import java.security.SecureRandom;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import org.jasypt.util.password.BasicPasswordEncryptor;

public class User extends HibernateObject
{

	static final String AB = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	static SecureRandom rnd = new SecureRandom();

	public static final String randomString(int len)
	{
		StringBuilder sb = new StringBuilder(len);

		for(int i = 0; i < len; i++)
		{
			sb.append(AB.charAt(rnd.nextInt(AB.length())));
		}

		return sb.toString();
	}

	private Integer userId;

	public Integer getUserId()
	{
		return userId;
	}

	public void setUserId(Integer userId)
	{
		this.userId = userId;
	}

	private String username;

	public String getUsername()
	{
		return username;
	}

	public void setUsername(String username)
	{
		this.username = username;
	}

	private String password;

	public String getPassword()
	{
		return password;
	}

	public void setPassword(String password)
	{
		this.password = password;
	}

	private String lastname;

	public String getLastname()
	{
		return lastname;
	}

	public void setLastname(String lastname)
	{
		this.lastname = lastname;
	}

	private String firstname;

	public String getFirstname()
	{
		return firstname;
	}

	public void setFirstname(String firstname)
	{
		this.firstname = firstname;
	}

	private String email;

	public String getEmail()
	{
		return email;
	}

	public void setEmail(String email)
	{
		this.email = email;
	}
	
	private String passwordinit;

	public String getPasswordinit()
	{
		return passwordinit;
	}

	public void setPasswordinit(String passwordinit)
	{
		this.passwordinit = passwordinit;
	}

	private Boolean haspaidentryfee;

	public Boolean isHaspaidentryfee()
	{
		return haspaidentryfee;
	}

	public void setHaspaidentryfee(Boolean haspaidentryfee)
	{
		this.haspaidentryfee = haspaidentryfee;
	}

	private Set userRoles = new HashSet();

	public Set getUserRoles()
	{
		return userRoles;
	}

	public void setUserRoles(Set userRoles)
	{
		this.userRoles = userRoles;
	}
	
	private Set userBetgroups = new HashSet();

	public Set getUserBetgroups()
	{
		return userBetgroups;
	}

	public void setUserBetgroups(Set userBetgroups)
	{
		this.userBetgroups = userBetgroups;
	}
	
	public String getHaspaidentryfeetext()
	{
            if (this.isHaspaidentryfee()) {
                return "Ja";
            }
            else {
                return "Nein";
            }
	}

	public String getUserRolesAsString()
	{
		String result = "";
		
		Iterator<UserRole> iterUserRoles = getUserRoles().iterator();
		
		while (iterUserRoles.hasNext() == true)
		{
			UserRole nextUserRole = iterUserRoles.next();
			
			if (result.length() > 0)
			{
				result = result.concat(", ");
			}
			
			result = result.concat(nextUserRole.getRole().getRolename());
		}
		
		return result;
	}
	
	public String getUserBetgroupsAsString()
	{
		String result = "";
		
		Iterator<UserBetgroup> iterUserBetgroups = getUserBetgroups().iterator();
		
		while (iterUserBetgroups.hasNext() == true)
		{
			UserBetgroup nextUserBetgroup = iterUserBetgroups.next();
			
			if (result.length() > 0)
			{
				result = result.concat(", ");
			}
			
			result = result.concat(nextUserBetgroup.getBetgroup().getBetgroupname());
		}
		
		return result;
	}
	
	public Set createUserRoles(Set roles)
	{
		Set resultSet = new HashSet();
		
		Iterator<Role> iterRoles = roles.iterator();
		
		while (iterRoles.hasNext() == true)
		{
			UserRole userRole = new UserRole();
			userRole.setUser(this);
			userRole.setRole(iterRoles.next());
			
			resultSet.add(userRole);
		}
		
		return resultSet;
	}
	
	public void mergeRoles(Set roles)
	{
		Set newUserRoles = createUserRoles(roles);
		
		this.getUserRoles().addAll(newUserRoles);
		this.getUserRoles().retainAll(newUserRoles);
	}
	
	public Set createUserBetgroups(Set betgroups)
	{
		Set resultSet = new HashSet();
		
		Iterator<Betgroup> iterBetgroups = betgroups.iterator();
		
		while (iterBetgroups.hasNext() == true)
		{
			UserBetgroup userBetgroup = new UserBetgroup();
			userBetgroup.setUser(this);
			userBetgroup.setBetgroup(iterBetgroups.next());
			
			resultSet.add(userBetgroup);
		}
		
		return resultSet;
	}
	
	public void mergeBetgroups(Set betgroups)
	{
		Set newUserBetgroup = createUserBetgroups(betgroups);
		
		this.getUserBetgroups().addAll(newUserBetgroup);
		this.getUserBetgroups().retainAll(newUserBetgroup);
	}
	
	public void setPasswordEncrypted(String password)
	{
		BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
		String encryptedPassword = passwordEncryptor.encryptPassword(password);

		setPassword(encryptedPassword);
	}
	
	public Boolean isUserPassword(String password)
	{
		BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
		
		return (passwordEncryptor.checkPassword(password, getPassword()) == true);
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getUsername());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}

	public static void insert(User object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void modify(User object)
	{
		try
		{
			beginTransaction();
			getSession().update(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void delete(User object)
	{
		try
		{
			beginTransaction();
			getSession().delete(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static User getById(int id)
	{
		try
		{
			beginTransaction();
			
			User result = (User) getSession()
					.getNamedQuery("getUserById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static User getByName(String name)
	{
		try
		{
			beginTransaction();
			
			User result = (User) getSession()
					.getNamedQuery("getUserByName")
					.setString("name", name)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static List getListAll()
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getUsersAll")
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}